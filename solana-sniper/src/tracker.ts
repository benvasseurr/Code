/**
 * tracker.ts
 * Subscribes to Solana WebSocket logs for tracked dev wallets.
 * Detects new SPL token mints created via pump.fun or Raydium.
 */

import {
  Connection,
  PublicKey,
  ParsedTransactionWithMeta,
  PartiallyDecodedInstruction,
  ParsedInstruction,
} from '@solana/web3.js';
import { EventEmitter } from 'events';
import { getConfig, PUMP_FUN_PROGRAM_ID, RAYDIUM_AMM_PROGRAM_ID, TOKEN_PROGRAM_ID } from './config';
import { NewTokenEvent, WalletStore } from './types';
import { logger } from './logger';
import { loadWalletStore, saveWalletStore, recordNewToken, refreshTokenStats } from './analyzer';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface TrackerEvents {
  newToken: (event: NewTokenEvent) => void;
  error: (err: Error) => void;
}

// ─── Constants ────────────────────────────────────────────────────────────────

// pump.fun "create" instruction discriminator (first 8 bytes of the IX data)
const PUMP_FUN_CREATE_DISCRIMINATOR = Buffer.from([24, 30, 200, 40, 5, 28, 7, 119]);

// Raydium AMM "initialize2" instruction index (opcode 1)
const RAYDIUM_INIT_OPCODE = 1;

/** How often to poll tracked wallets for recent txns (ms) */
const POLL_INTERVAL_MS = 15_000;

/** How often to refresh token stats (ms) */
const STATS_REFRESH_MS = 5 * 60_000;

// ─── Tracker ─────────────────────────────────────────────────────────────────

export class WalletTracker extends EventEmitter {
  private connection: Connection;
  private wsConnection: Connection;
  private store: WalletStore;
  private subscriptions: Map<string, number> = new Map(); // address → subscriptionId
  private pollTimer?: NodeJS.Timeout;
  private statsTimer?: NodeJS.Timeout;
  private running = false;

  constructor() {
    super();
    const cfg = getConfig();
    this.connection = new Connection(cfg.rpcUrl, 'confirmed');
    this.wsConnection = new Connection(cfg.wsUrl, {
      commitment: 'confirmed',
      wsEndpoint: cfg.wsUrl,
    });
    this.store = loadWalletStore();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  getStore(): WalletStore {
    return this.store;
  }

  reloadStore(): void {
    this.store = loadWalletStore();
  }

  async start(): Promise<void> {
    if (this.running) return;
    this.running = true;
    logger.info('WalletTracker starting…');

    await this.subscribeAll();

    // Periodic polling as backup (WebSocket can miss events)
    this.pollTimer = setInterval(() => this.pollAll(), POLL_INTERVAL_MS);

    // Periodic stats refresh
    this.statsTimer = setInterval(() => this.refreshAllStats(), STATS_REFRESH_MS);

    logger.info('WalletTracker running', { wallets: Object.keys(this.store.wallets).length });
  }

  async stop(): Promise<void> {
    this.running = false;
    if (this.pollTimer) clearInterval(this.pollTimer);
    if (this.statsTimer) clearInterval(this.statsTimer);
    for (const [address, subId] of this.subscriptions) {
      try {
        await this.wsConnection.removeOnLogsListener(subId);
        logger.debug('Unsubscribed', { address });
      } catch (_) { /* ignore */ }
    }
    this.subscriptions.clear();
    logger.info('WalletTracker stopped');
  }

  /** Dynamically add a wallet subscription without restarting */
  async subscribeWallet(address: string): Promise<void> {
    if (this.subscriptions.has(address)) return;
    try {
      const pubkey = new PublicKey(address);
      const subId = this.wsConnection.onLogs(
        pubkey,
        async (logs) => {
          if (logs.err) return;
          await this.handleLogs(address, logs.signature, logs.logs);
        },
        'confirmed',
      );
      this.subscriptions.set(address, subId);
      logger.debug('WebSocket subscribed', { address });
    } catch (err) {
      logger.warn('Failed to subscribe to wallet', { address, err });
    }
  }

  async unsubscribeWallet(address: string): Promise<void> {
    const subId = this.subscriptions.get(address);
    if (subId === undefined) return;
    try {
      await this.wsConnection.removeOnLogsListener(subId);
    } catch (_) { /* ignore */ }
    this.subscriptions.delete(address);
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  private async subscribeAll(): Promise<void> {
    const addresses = Object.keys(this.store.wallets);
    for (const address of addresses) {
      await this.subscribeWallet(address);
    }
  }

  private async pollAll(): Promise<void> {
    const addresses = Object.keys(this.store.wallets);
    for (const address of addresses) {
      await this.pollWallet(address);
    }
    saveWalletStore(this.store);
  }

  private async pollWallet(address: string): Promise<void> {
    try {
      const pubkey = new PublicKey(address);
      const sigs = await this.connection.getSignaturesForAddress(pubkey, { limit: 10 });
      for (const sig of sigs) {
        if (sig.err) continue;
        await this.fetchAndProcessTx(address, sig.signature);
      }
    } catch (err) {
      logger.debug('Poll error', { address, err });
    }
  }

  private async handleLogs(devAddress: string, signature: string, logs: string[]): Promise<void> {
    try {
      // Quick pre-filter: does this tx touch a known token-creation program?
      const logStr = logs.join(' ');
      const isPumpFun = logStr.includes(PUMP_FUN_PROGRAM_ID);
      const isRaydium = logStr.includes(RAYDIUM_AMM_PROGRAM_ID);
      const isTokenProgram = logStr.includes('Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      if (!isPumpFun && !isRaydium && !isTokenProgram) return;

      await this.fetchAndProcessTx(devAddress, signature);
    } catch (err) {
      logger.debug('Log handler error', { devAddress, signature, err });
    }
  }

  private async fetchAndProcessTx(devAddress: string, signature: string): Promise<void> {
    try {
      const tx = await this.connection.getParsedTransaction(signature, {
        maxSupportedTransactionVersion: 0,
        commitment: 'confirmed',
      });
      if (!tx || tx.meta?.err) return;

      const event = await this.detectNewToken(devAddress, signature, tx);
      if (event) {
        logger.info('New token detected via tx', { ...event });

        // Record in store
        recordNewToken(this.store, devAddress, event.mint, event.platform, event.name, event.symbol);
        saveWalletStore(this.store);

        this.emit('newToken', event);

        // Kick off a background stats refresh after 60s to catch initial price
        setTimeout(() => {
          refreshTokenStats(this.store, devAddress, event.mint)
            .then(() => saveWalletStore(this.store))
            .catch((e) => logger.debug('Stats refresh error', { e }));
        }, 60_000);
      }
    } catch (err) {
      logger.debug('fetchAndProcessTx error', { signature, err });
    }
  }

  /**
   * Inspects a parsed transaction to determine if the dev created a new token mint.
   * Returns a NewTokenEvent if detected, otherwise null.
   */
  private async detectNewToken(
    devAddress: string,
    signature: string,
    tx: ParsedTransactionWithMeta,
  ): Promise<NewTokenEvent | null> {
    const accountKeys = tx.transaction.message.accountKeys.map((k) =>
      typeof k === 'string' ? k : k.pubkey.toBase58(),
    );

    // Check if devAddress is a signer
    const signers = tx.transaction.message.accountKeys
      .filter((k) => (typeof k === 'object' ? k.signer : false))
      .map((k) => (typeof k === 'object' ? k.pubkey.toBase58() : k));

    if (!signers.includes(devAddress)) return null;

    const instructions = tx.transaction.message.instructions;
    let platform: 'pump.fun' | 'raydium' | 'unknown' = 'unknown';
    let mint: string | null = null;

    for (const ix of instructions) {
      const programId = ix.programId.toBase58();

      // ── pump.fun detection ──────────────────────────────────────────────────
      if (programId === PUMP_FUN_PROGRAM_ID) {
        // The mint account is typically the 2nd account in a pump.fun create ix
        const accounts =
          'accounts' in ix
            ? (ix as PartiallyDecodedInstruction).accounts?.map((a) => a.toBase58())
            : undefined;

        if (accounts && accounts.length >= 2) {
          // Validate: check discriminator on raw data
          const rawData =
            'data' in ix ? (ix as PartiallyDecodedInstruction).data : undefined;

          if (rawData) {
            const buf = Buffer.from(rawData, 'base64');
            const matches = PUMP_FUN_CREATE_DISCRIMINATOR.every(
              (b, i) => buf[i] === b,
            );
            if (matches) {
              mint = accounts[0]; // mint is first account
              platform = 'pump.fun';
              break;
            }
          }

          // Fallback: any pump.fun ix with "initializeMint" in inner logs
          const innerLogs = tx.meta?.logMessages ?? [];
          const hasMintInit = innerLogs.some(
            (l) => l.includes('InitializeMint') || l.includes('initializeMint'),
          );
          if (hasMintInit) {
            // Try to extract mint from postTokenBalances or inner instructions
            mint = this.extractMintFromTx(tx);
            if (mint) {
              platform = 'pump.fun';
              break;
            }
          }
        }
      }

      // ── Raydium detection ──────────────────────────────────────────────────
      if (programId === RAYDIUM_AMM_PROGRAM_ID) {
        const rawData =
          'data' in ix ? (ix as PartiallyDecodedInstruction).data : undefined;
        if (rawData) {
          const buf = Buffer.from(rawData, 'base64');
          if (buf[0] === RAYDIUM_INIT_OPCODE) {
            mint = this.extractMintFromTx(tx);
            if (mint) {
              platform = 'raydium';
              break;
            }
          }
        }
      }

      // ── Generic SPL token InitializeMint ───────────────────────────────────
      if (programId === TOKEN_PROGRAM_ID) {
        const parsed = (ix as ParsedInstruction).parsed;
        if (
          parsed?.type === 'initializeMint' ||
          parsed?.type === 'initializeMint2'
        ) {
          mint = parsed.info?.mint ?? null;
          platform = 'unknown';
          // Don't break; prefer pump.fun/raydium match
        }
      }
    }

    // Also check inner instructions for pump.fun/Raydium create calls
    if (!mint) {
      for (const inner of tx.meta?.innerInstructions ?? []) {
        for (const ix of inner.instructions) {
          const programId = ix.programId.toBase58();

          if (programId === PUMP_FUN_PROGRAM_ID) {
            mint = this.extractMintFromTx(tx);
            if (mint) { platform = 'pump.fun'; break; }
          }
          if (programId === TOKEN_PROGRAM_ID) {
            const parsed = (ix as ParsedInstruction).parsed;
            if (parsed?.type === 'initializeMint' || parsed?.type === 'initializeMint2') {
              mint = parsed.info?.mint ?? null;
              platform = platform === 'unknown' ? 'unknown' : platform;
            }
          }
        }
        if (mint && platform !== 'unknown') break;
      }
    }

    if (!mint) return null;

    // Sanity: mint must be a valid pubkey and not a known system account
    try {
      new PublicKey(mint);
    } catch {
      return null;
    }

    return {
      mint,
      devAddress,
      platform,
      txSignature: signature,
      timestamp: Date.now(),
    };
  }

  private extractMintFromTx(tx: ParsedTransactionWithMeta): string | null {
    // Try postTokenBalances first
    const balances = tx.meta?.postTokenBalances ?? [];
    if (balances.length > 0) {
      return balances[0].mint;
    }

    // Try inner instructions for initializeMint
    for (const inner of tx.meta?.innerInstructions ?? []) {
      for (const ix of inner.instructions) {
        const parsed = (ix as ParsedInstruction).parsed;
        if (
          parsed?.type === 'initializeMint' ||
          parsed?.type === 'initializeMint2'
        ) {
          return parsed.info?.mint ?? null;
        }
      }
    }
    return null;
  }

  private async refreshAllStats(): Promise<void> {
    for (const dev of Object.values(this.store.wallets)) {
      // Refresh only tokens younger than 7 days that haven't been updated recently
      const staleTokens = dev.tokens.filter(
        (t) =>
          Date.now() - t.createdAt < 7 * 24 * 60 * 60 * 1000 &&
          Date.now() - t.lastUpdatedAt > STATS_REFRESH_MS,
      );
      for (const token of staleTokens) {
        try {
          await refreshTokenStats(this.store, dev.address, token.mint);
        } catch (err) {
          logger.debug('Stats refresh error', { mint: token.mint, err });
        }
        // Small delay between requests to avoid rate limits
        await sleep(500);
      }
    }
    saveWalletStore(this.store);
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((res) => setTimeout(res, ms));
}

/**
 * sniper.ts
 * Executes token buys via the Jupiter V6 swap API.
 * Triggered when a tracked dev deploys a new token that passes filters.
 */

import {
  Connection,
  Keypair,
  VersionedTransaction,
  PublicKey,
  TransactionConfirmationStrategy,
} from '@solana/web3.js';
import axios from 'axios';
import bs58 from 'bs58';
import {
  JupiterQuoteResponse,
  JupiterSwapResponse,
  SwapResult,
  NewTokenEvent,
  BuyConfig,
} from './types';
import { getConfig, SOL_MINT } from './config';
import { logger, logBuy } from './logger';
import { WalletStore } from './types';

// ─── Constants ────────────────────────────────────────────────────────────────

/** Delay after token detection before sniping (ms) – gives pool time to initialize */
const SNIPE_DELAY_MS = 2_000;

/** Maximum retries for quote / swap RPC failures */
const MAX_RETRIES = 3;

/** Timeout for Jupiter API calls (ms) */
const API_TIMEOUT_MS = 15_000;

// ─── Sniper ───────────────────────────────────────────────────────────────────

export class Sniper {
  private connection: Connection;
  private keypair: Keypair | null = null;
  private jupiterApiUrl: string;
  private buyConfig: BuyConfig;

  constructor() {
    const cfg = getConfig();
    this.connection = new Connection(cfg.rpcUrl, 'confirmed');
    this.jupiterApiUrl = cfg.jupiterApiUrl;
    this.buyConfig = cfg.buyConfig;

    if (cfg.privateKey) {
      try {
        const secretKey = bs58.decode(cfg.privateKey);
        this.keypair = Keypair.fromSecretKey(secretKey);
        logger.info('Sniper wallet loaded', {
          pubkey: this.keypair.publicKey.toBase58(),
        });
      } catch (err) {
        logger.error('Invalid PRIVATE_KEY in .env – sniper disabled', { err });
      }
    } else {
      logger.warn('No PRIVATE_KEY configured – running in watch-only mode');
    }
  }

  get walletAddress(): string | null {
    return this.keypair?.publicKey.toBase58() ?? null;
  }

  // ── Main entry point ────────────────────────────────────────────────────────

  /**
   * Evaluates a new token event against filters and fires a buy if appropriate.
   * @param event  Newly detected token event from the tracker
   * @param store  Current wallet store (for dev score lookup)
   * @param overrideConfig  Optional per-call buy config override
   */
  async maybeSnipe(
    event: NewTokenEvent,
    store: WalletStore,
    overrideConfig?: Partial<BuyConfig>,
  ): Promise<SwapResult | null> {
    if (!this.keypair) {
      logger.debug('Sniper disabled (no keypair) – skipping', { mint: event.mint });
      return null;
    }

    const cfg = getConfig();
    const dev = store.wallets[event.devAddress];

    if (!dev) {
      logger.debug('Dev not in store – skipping', { devAddress: event.devAddress });
      return null;
    }

    if (dev.score < cfg.minDevScore) {
      logger.info('Dev score too low – skipping', {
        devAddress: event.devAddress,
        score: dev.score,
        minScore: cfg.minDevScore,
      });
      return null;
    }

    logger.info('Snipe triggered', {
      mint: event.mint,
      devAddress: event.devAddress,
      score: dev.score,
      platform: event.platform,
    });

    // Brief delay so liquidity pools can initialize
    await sleep(SNIPE_DELAY_MS);

    const buyConf: BuyConfig = { ...this.buyConfig, ...overrideConfig };
    const result = await this.buy(event.mint, buyConf);

    logBuy(event.mint, event.devAddress, buyConf.amountSol, result.txSignature, result.error);
    return result;
  }

  // ── Jupiter swap flow ───────────────────────────────────────────────────────

  async buy(mint: string, buyConf: BuyConfig): Promise<SwapResult> {
    const lamports = Math.round(buyConf.amountSol * 1e9);

    let quote: JupiterQuoteResponse | null = null;
    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        quote = await this.getQuote(mint, lamports, buyConf.slippageBps);
        break;
      } catch (err) {
        logger.warn(`Jupiter quote failed (attempt ${attempt}/${MAX_RETRIES})`, { mint, err });
        if (attempt === MAX_RETRIES) {
          return {
            success: false,
            error: `Quote failed after ${MAX_RETRIES} attempts: ${String(err)}`,
            inputAmount: lamports,
            mint,
          };
        }
        await sleep(1000 * attempt);
      }
    }

    if (!quote) {
      return { success: false, error: 'No quote received', inputAmount: lamports, mint };
    }

    logger.info('Jupiter quote received', {
      mint,
      inAmount: quote.inAmount,
      outAmount: quote.outAmount,
      priceImpact: quote.priceImpactPct,
    });

    // Check price impact
    const priceImpact = parseFloat(quote.priceImpactPct);
    if (priceImpact > 20) {
      logger.warn('Price impact too high – aborting snipe', { mint, priceImpact });
      return {
        success: false,
        error: `Price impact ${priceImpact.toFixed(2)}% exceeds 20% limit`,
        inputAmount: lamports,
        mint,
      };
    }

    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        const swapTx = await this.getSwapTransaction(quote, buyConf.priorityFeeMicrolamports);
        const sig = await this.sendAndConfirmSwap(swapTx);
        return {
          success: true,
          txSignature: sig,
          inputAmount: lamports,
          outputAmount: parseInt(quote.outAmount, 10),
          mint,
        };
      } catch (err) {
        logger.warn(`Swap attempt ${attempt}/${MAX_RETRIES} failed`, { mint, err });
        if (attempt === MAX_RETRIES) {
          return {
            success: false,
            error: `Swap failed after ${MAX_RETRIES} attempts: ${String(err)}`,
            inputAmount: lamports,
            mint,
          };
        }
        await sleep(1500 * attempt);
      }
    }

    return { success: false, error: 'Unexpected sniper error', inputAmount: lamports, mint };
  }

  // ── Jupiter API helpers ─────────────────────────────────────────────────────

  private async getQuote(
    outputMint: string,
    inputLamports: number,
    slippageBps: number,
  ): Promise<JupiterQuoteResponse> {
    const params = new URLSearchParams({
      inputMint: SOL_MINT,
      outputMint,
      amount: String(inputLamports),
      slippageBps: String(slippageBps),
      onlyDirectRoutes: 'false',
      asLegacyTransaction: 'false',
    });

    const res = await axios.get<JupiterQuoteResponse>(
      `${this.jupiterApiUrl}/quote?${params.toString()}`,
      { timeout: API_TIMEOUT_MS },
    );

    if (!res.data?.outAmount) {
      throw new Error(`Invalid quote response: ${JSON.stringify(res.data)}`);
    }

    return res.data;
  }

  private async getSwapTransaction(
    quote: JupiterQuoteResponse,
    priorityFeeMicrolamports: number,
  ): Promise<string> {
    if (!this.keypair) throw new Error('No keypair');

    const body = {
      quoteResponse: quote,
      userPublicKey: this.keypair.publicKey.toBase58(),
      wrapAndUnwrapSol: true,
      prioritizationFeeLamports: priorityFeeMicrolamports,
      dynamicComputeUnitLimit: true,
      asLegacyTransaction: false,
    };

    const res = await axios.post<JupiterSwapResponse>(
      `${this.jupiterApiUrl}/swap`,
      body,
      {
        headers: { 'Content-Type': 'application/json' },
        timeout: API_TIMEOUT_MS,
      },
    );

    if (!res.data?.swapTransaction) {
      throw new Error(`Invalid swap response: ${JSON.stringify(res.data)}`);
    }

    return res.data.swapTransaction;
  }

  private async sendAndConfirmSwap(swapTransactionBase64: string): Promise<string> {
    if (!this.keypair) throw new Error('No keypair');

    const txBuffer = Buffer.from(swapTransactionBase64, 'base64');
    const transaction = VersionedTransaction.deserialize(txBuffer);

    // Sign the transaction
    transaction.sign([this.keypair]);

    const rawTx = transaction.serialize();

    // Send with skip preflight for speed
    const signature = await this.connection.sendRawTransaction(rawTx, {
      skipPreflight: true,
      maxRetries: 3,
      preflightCommitment: 'confirmed',
    });

    logger.info('Transaction sent', { signature });

    // Confirm
    const latestBlockhash = await this.connection.getLatestBlockhash('confirmed');
    const confirmStrategy: TransactionConfirmationStrategy = {
      signature,
      blockhash: latestBlockhash.blockhash,
      lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
    };

    const confirmation = await this.connection.confirmTransaction(
      confirmStrategy,
      'confirmed',
    );

    if (confirmation.value.err) {
      throw new Error(`Transaction failed on-chain: ${JSON.stringify(confirmation.value.err)}`);
    }

    logger.info('Transaction confirmed', { signature });
    return signature;
  }

  // ── Simulation / dry-run ────────────────────────────────────────────────────

  /** Simulate a buy without sending – useful for testing */
  async simulateBuy(mint: string, buyConf?: Partial<BuyConfig>): Promise<void> {
    const conf = { ...this.buyConfig, ...buyConf };
    const lamports = Math.round(conf.amountSol * 1e9);

    logger.info('[DRY RUN] Simulating buy', { mint, amountSol: conf.amountSol });

    try {
      const quote = await this.getQuote(mint, lamports, conf.slippageBps);
      const outAmount = parseInt(quote.outAmount, 10);
      logger.info('[DRY RUN] Quote result', {
        mint,
        inSol: conf.amountSol,
        outTokens: outAmount,
        priceImpact: quote.priceImpactPct,
        slippageBps: quote.slippageBps,
      });
    } catch (err) {
      logger.error('[DRY RUN] Quote failed', { mint, err });
    }
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

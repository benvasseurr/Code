/**
 * index.ts
 * Main entry point.  Supports two modes:
 *   1. `ts-node src/index.ts` or `node dist/index.js`
 *      → starts the tracker + sniper daemon
 *   2. CLI sub-commands for wallet management:
 *      add-wallet <address> [alias]
 *      remove-wallet <address>
 *      leaderboard
 *      simulate <mint>
 */

import 'dotenv/config';
import { Command } from 'commander';
import { WalletTracker } from './tracker';
import { Sniper } from './sniper';
import { NewTokenEvent } from './types';
import { logger } from './logger';
import {
  loadWalletStore,
  saveWalletStore,
  addTrackedWallet,
  removeTrackedWallet,
  getLeaderboard,
} from './analyzer';

// ─── CLI Definition ───────────────────────────────────────────────────────────

const program = new Command();

program
  .name('solana-sniper')
  .description('Solana dev-wallet tracker & sniping bot')
  .version('1.0.0');

// ── add-wallet ────────────────────────────────────────────────────────────────

program
  .command('add-wallet <address> [alias]')
  .description('Add a dev wallet to the tracking list')
  .action(async (address: string, alias?: string) => {
    const store = loadWalletStore();
    const dev = addTrackedWallet(store, address, alias);
    console.log(`✔  Added wallet: ${dev.address}${dev.alias ? ` (${dev.alias})` : ''}`);
    process.exit(0);
  });

// ── remove-wallet ─────────────────────────────────────────────────────────────

program
  .command('remove-wallet <address>')
  .description('Remove a dev wallet from tracking')
  .action(async (address: string) => {
    const store = loadWalletStore();
    const removed = removeTrackedWallet(store, address);
    if (removed) {
      console.log(`✔  Removed wallet: ${address}`);
    } else {
      console.error(`✗  Wallet not found: ${address}`);
    }
    process.exit(0);
  });

// ── leaderboard ───────────────────────────────────────────────────────────────

program
  .command('leaderboard')
  .description('Show tracked dev wallets ranked by score')
  .option('-n, --top <n>', 'Number of wallets to show', '20')
  .action((opts) => {
    const store = loadWalletStore();
    const ranked = getLeaderboard(store).slice(0, parseInt(opts.top, 10));
    if (ranked.length === 0) {
      console.log('No wallets tracked yet. Use `add-wallet` to get started.');
      process.exit(0);
    }

    console.log('\n  ─── Dev Wallet Leaderboard ─────────────────────────────────');
    console.log(
      `  ${'#'.padEnd(3)} ${'Alias/Address'.padEnd(24)} ${'Score'.padEnd(6)} ${'Wins'.padEnd(5)} ${'Rugs'.padEnd(5)} ${'Tokens'.padEnd(7)} ${'Avg Peak MC'}`,
    );
    console.log('  ' + '─'.repeat(70));

    ranked.forEach((dev, i) => {
      const label = (dev.alias ?? dev.address).slice(0, 24).padEnd(24);
      const score = dev.score.toFixed(1).padEnd(6);
      const wins = String(dev.wins).padEnd(5);
      const rugs = String(dev.rugs).padEnd(5);
      const total = String(dev.totalTokens).padEnd(7);
      const avgMc = fmtUsd(dev.avgPeakMarketCapUsd);
      console.log(`  ${String(i + 1).padEnd(3)} ${label} ${score} ${wins} ${rugs} ${total} ${avgMc}`);
    });

    console.log('');
    process.exit(0);
  });

// ── simulate ──────────────────────────────────────────────────────────────────

program
  .command('simulate <mint>')
  .description('Dry-run a Jupiter swap for a given token mint (no real buy)')
  .option('--sol <amount>', 'SOL amount to simulate', '0.1')
  .option('--slippage <bps>', 'Slippage in bps', '500')
  .action(async (mint: string, opts) => {
    const sniper = new Sniper();
    await sniper.simulateBuy(mint, {
      amountSol: parseFloat(opts.sol),
      slippageBps: parseInt(opts.slippage, 10),
    });
    process.exit(0);
  });

// ── track (daemon) ────────────────────────────────────────────────────────────

program
  .command('track', { isDefault: true })
  .description('Start the tracker + sniper daemon (default command)')
  .option('--dry-run', 'Watch-only mode – detect but do not buy', false)
  .action(async (opts) => {
    await runDaemon(opts.dryRun as boolean);
  });

// ─── Daemon ───────────────────────────────────────────────────────────────────

async function runDaemon(dryRun: boolean): Promise<void> {
  logger.info('Starting Solana Sniper Bot', { dryRun, pid: process.pid });

  const tracker = new WalletTracker();
  const sniper = new Sniper();

  // Handle new token events
  tracker.on('newToken', async (event: NewTokenEvent) => {
    logger.info('EVENT: newToken', {
      mint: event.mint,
      dev: event.devAddress,
      platform: event.platform,
    });

    if (dryRun) {
      logger.info('[DRY RUN] Would snipe', { mint: event.mint, dev: event.devAddress });
      return;
    }

    try {
      const store = tracker.getStore();
      const result = await sniper.maybeSnipe(event, store);
      if (result?.success) {
        logger.info('Snipe success', { txSig: result.txSignature, mint: event.mint });
      } else if (result) {
        logger.warn('Snipe skipped/failed', { error: result.error, mint: event.mint });
      }
    } catch (err) {
      logger.error('Snipe error', { err, mint: event.mint });
    }
  });

  tracker.on('error', (err: Error) => {
    logger.error('Tracker error', { err });
  });

  await tracker.start();

  const store = tracker.getStore();
  const walletCount = Object.keys(store.wallets).length;
  logger.info(`Daemon running – tracking ${walletCount} wallet(s)`);
  if (walletCount === 0) {
    logger.warn('No wallets tracked. Use `add-wallet <address>` to add devs to watch.');
  }

  // Graceful shutdown
  const shutdown = async (signal: string) => {
    logger.info(`Received ${signal} – shutting down…`);
    await tracker.stop();
    saveWalletStore(store);
    process.exit(0);
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('uncaughtException', (err) => {
    logger.error('Uncaught exception', { err });
  });
  process.on('unhandledRejection', (reason) => {
    logger.error('Unhandled rejection', { reason });
  });

  // Keep process alive
  await forever();
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function fmtUsd(n: number): string {
  if (n >= 1_000_000) return `$${(n / 1_000_000).toFixed(2)}M`;
  if (n >= 1_000) return `$${(n / 1_000).toFixed(1)}K`;
  return `$${n.toFixed(0)}`;
}

function forever(): Promise<never> {
  return new Promise(() => {});
}

// ─── Parse & Run ─────────────────────────────────────────────────────────────

program.parse(process.argv);

/**
 * analyzer.ts
 * Scores dev wallets based on historical token performance.
 * Score formula (0–100):
 *   - Win rate weight         : 40 pts
 *   - Avg peak market cap     : 30 pts  (log-scaled, capped at $10M)
 *   - Rug rate penalty        : -20 pts (proportional to rug fraction)
 *   - Activity recency bonus  : 10 pts
 */

import fs from 'fs';
import path from 'path';
import axios from 'axios';
import { DevWallet, TokenRecord, WalletStore, MarketCapData } from './types';
import { getConfig, WIN_MARKET_CAP_USD, RUG_WINDOW_MS } from './config';
import { logger, logDevScore } from './logger';

const WALLET_STORE_FILE = () => path.join(getConfig().dataDir, 'wallets.json');

// ─── Persistence ─────────────────────────────────────────────────────────────

export function loadWalletStore(): WalletStore {
  const file = WALLET_STORE_FILE();
  if (fs.existsSync(file)) {
    try {
      const raw = fs.readFileSync(file, 'utf-8');
      return JSON.parse(raw) as WalletStore;
    } catch (err) {
      logger.warn('Failed to parse wallet store, starting fresh', { err });
    }
  }
  return { wallets: {}, lastSaved: Date.now() };
}

export function saveWalletStore(store: WalletStore): void {
  const file = WALLET_STORE_FILE();
  fs.mkdirSync(path.dirname(file), { recursive: true });
  store.lastSaved = Date.now();
  fs.writeFileSync(file, JSON.stringify(store, null, 2));
}

// ─── Score Calculation ────────────────────────────────────────────────────────

export function computeDevScore(dev: DevWallet): number {
  const tokens = dev.tokens;
  if (tokens.length === 0) return 0;

  // Win rate (40 pts)
  const wins = tokens.filter((t) => t.peakMarketCapUsd >= WIN_MARKET_CAP_USD).length;
  const winRate = wins / tokens.length;
  const winScore = winRate * 40;

  // Avg peak market cap log-scaled to $10M → 30 pts
  const avgPeak =
    tokens.reduce((s, t) => s + t.peakMarketCapUsd, 0) / tokens.length;
  const CAP_MAX = 10_000_000;
  const logScore =
    avgPeak > 0
      ? Math.min(Math.log10(avgPeak) / Math.log10(CAP_MAX), 1) * 30
      : 0;

  // Rug rate penalty (up to -20 pts)
  const rugs = tokens.filter((t) => t.rugProbability > 0.7).length;
  const rugPenalty = (rugs / tokens.length) * 20;

  // Recency bonus (10 pts if active in last 7 days)
  const daysSinceLast = dev.lastActivity
    ? (Date.now() - dev.lastActivity) / (1000 * 60 * 60 * 24)
    : 999;
  const recencyBonus = daysSinceLast < 7 ? 10 : daysSinceLast < 30 ? 5 : 0;

  const score = Math.max(0, Math.min(100, winScore + logScore - rugPenalty + recencyBonus));
  return Math.round(score * 10) / 10;
}

// ─── Market Cap Fetching ──────────────────────────────────────────────────────

/**
 * Fetch current market cap data from DexScreener (free, no API key needed).
 */
export async function fetchMarketCapData(mint: string): Promise<MarketCapData | null> {
  try {
    const url = `https://api.dexscreener.com/latest/dex/tokens/${mint}`;
    const res = await axios.get<{
      pairs: Array<{
        priceUsd?: string;
        fdv?: number;
        volume?: { h24?: number };
        liquidity?: { usd?: number };
      }>;
    }>(url, { timeout: 8000 });

    const pairs = res.data?.pairs;
    if (!pairs || pairs.length === 0) return null;

    // Pick highest liquidity pair
    const pair = pairs.sort(
      (a, b) => (b.liquidity?.usd ?? 0) - (a.liquidity?.usd ?? 0),
    )[0];

    return {
      mint,
      marketCapUsd: pair.fdv ?? 0,
      volumeUsd24h: pair.volume?.h24 ?? 0,
      liquidityUsd: pair.liquidity?.usd ?? 0,
      timestamp: Date.now(),
    };
  } catch (err) {
    logger.debug('Failed to fetch market cap data', { mint, err });
    return null;
  }
}

// ─── Token Record Management ──────────────────────────────────────────────────

export function getOrCreateDevWallet(store: WalletStore, address: string): DevWallet {
  if (!store.wallets[address]) {
    store.wallets[address] = {
      address,
      addedAt: Date.now(),
      score: 0,
      tokens: [],
      totalTokens: 0,
      wins: 0,
      rugs: 0,
      avgPeakMarketCapUsd: 0,
      lastActivity: undefined,
    };
  }
  return store.wallets[address];
}

export function recordNewToken(
  store: WalletStore,
  devAddress: string,
  mint: string,
  platform: 'pump.fun' | 'raydium' | 'unknown',
  name?: string,
  symbol?: string,
): TokenRecord {
  const dev = getOrCreateDevWallet(store, devAddress);
  const existing = dev.tokens.find((t) => t.mint === mint);
  if (existing) return existing;

  const record: TokenRecord = {
    mint,
    name,
    symbol,
    createdAt: Date.now(),
    platform,
    peakMarketCapUsd: 0,
    peakVolumeUsd: 0,
    rugProbability: 0,
    lastUpdatedAt: Date.now(),
  };

  dev.tokens.push(record);
  dev.totalTokens++;
  dev.lastActivity = Date.now();

  // Trim to max
  const max = getConfig().maxTokensToTrack;
  if (dev.tokens.length > max) {
    dev.tokens = dev.tokens.slice(-max);
  }

  return record;
}

export async function refreshTokenStats(
  store: WalletStore,
  devAddress: string,
  mint: string,
): Promise<void> {
  const dev = store.wallets[devAddress];
  if (!dev) return;

  const record = dev.tokens.find((t) => t.mint === mint);
  if (!record) return;

  const data = await fetchMarketCapData(mint);
  if (!data) return;

  if (data.marketCapUsd > record.peakMarketCapUsd) {
    record.peakMarketCapUsd = data.marketCapUsd;
  }
  if (data.volumeUsd24h > record.peakVolumeUsd) {
    record.peakVolumeUsd = data.volumeUsd24h;
  }
  record.lastUpdatedAt = Date.now();

  // Rug detection: liquidity < 1% of peak market cap after first hour
  const ageMs = Date.now() - record.createdAt;
  if (
    ageMs > 60 * 60 * 1000 &&
    record.peakMarketCapUsd > 0 &&
    data.liquidityUsd < record.peakMarketCapUsd * 0.01
  ) {
    if (!record.liquidityRemovedAt) {
      record.liquidityRemovedAt = Date.now();
    }
    const rugAge = Date.now() - record.liquidityRemovedAt;
    record.rugProbability = Math.min(1, rugAge / RUG_WINDOW_MS);
  }

  // Recompute aggregate stats
  dev.wins = dev.tokens.filter((t) => t.peakMarketCapUsd >= WIN_MARKET_CAP_USD).length;
  dev.rugs = dev.tokens.filter((t) => t.rugProbability > 0.7).length;
  dev.avgPeakMarketCapUsd =
    dev.tokens.reduce((s, t) => s + t.peakMarketCapUsd, 0) / dev.tokens.length;

  dev.score = computeDevScore(dev);
  logDevScore(devAddress, dev.score, dev.alias);
}

// ─── Leaderboard ──────────────────────────────────────────────────────────────

export function getLeaderboard(store: WalletStore): DevWallet[] {
  return Object.values(store.wallets).sort((a, b) => b.score - a.score);
}

export function addTrackedWallet(
  store: WalletStore,
  address: string,
  alias?: string,
): DevWallet {
  const dev = getOrCreateDevWallet(store, address);
  if (alias) dev.alias = alias;
  saveWalletStore(store);
  logger.info('Wallet added to tracking', { address, alias });
  return dev;
}

export function removeTrackedWallet(store: WalletStore, address: string): boolean {
  if (!store.wallets[address]) return false;
  delete store.wallets[address];
  saveWalletStore(store);
  logger.info('Wallet removed from tracking', { address });
  return true;
}

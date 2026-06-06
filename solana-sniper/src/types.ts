// ─── Shared Types ────────────────────────────────────────────────────────────

export interface TokenRecord {
  mint: string;
  name?: string;
  symbol?: string;
  createdAt: number; // unix ms
  platform: 'pump.fun' | 'raydium' | 'unknown';
  peakMarketCapUsd: number;
  peakVolumeUsd: number;
  liquidityRemovedAt?: number; // unix ms – signals rug
  rugProbability: number; // 0-1
  lastUpdatedAt: number; // unix ms
}

export interface DevWallet {
  address: string;
  alias?: string;
  addedAt: number; // unix ms
  score: number; // 0-100 composite score
  tokens: TokenRecord[];
  totalTokens: number;
  wins: number; // tokens with peakMarketCap > threshold
  rugs: number;
  avgPeakMarketCapUsd: number;
  lastActivity?: number; // unix ms
}

export interface WalletStore {
  wallets: Record<string, DevWallet>; // keyed by address
  lastSaved: number;
}

export interface BuyConfig {
  amountSol: number;
  slippageBps: number;
  priorityFeeMicrolamports: number;
}

export interface SwapResult {
  success: boolean;
  txSignature?: string;
  error?: string;
  inputAmount: number;
  outputAmount?: number;
  mint: string;
}

export interface NewTokenEvent {
  mint: string;
  devAddress: string;
  platform: 'pump.fun' | 'raydium' | 'unknown';
  txSignature: string;
  timestamp: number;
  name?: string;
  symbol?: string;
}

export interface JupiterQuoteResponse {
  inputMint: string;
  inAmount: string;
  outputMint: string;
  outAmount: string;
  otherAmountThreshold: string;
  swapMode: string;
  slippageBps: number;
  priceImpactPct: string;
  routePlan: unknown[];
  contextSlot?: number;
  timeTaken?: number;
}

export interface JupiterSwapResponse {
  swapTransaction: string;
  lastValidBlockHeight: number;
  prioritizationFeeLamports?: number;
}

export interface MarketCapData {
  mint: string;
  marketCapUsd: number;
  volumeUsd24h: number;
  liquidityUsd: number;
  timestamp: number;
}

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

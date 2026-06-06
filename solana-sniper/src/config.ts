import dotenv from 'dotenv';
import path from 'path';
import { BuyConfig } from './types';

dotenv.config();

function requireEnv(key: string): string {
  const val = process.env[key];
  if (!val) throw new Error(`Missing required environment variable: ${key}`);
  return val;
}

function optionalEnv(key: string, defaultVal: string): string {
  return process.env[key] ?? defaultVal;
}

export interface AppConfig {
  rpcUrl: string;
  wsUrl: string;
  privateKey: string;
  buyConfig: BuyConfig;
  minDevScore: number;
  maxTokensToTrack: number;
  jupiterApiUrl: string;
  dataDir: string;
  logLevel: string;
  logFile: string;
}

let _config: AppConfig | null = null;

export function getConfig(): AppConfig {
  if (_config) return _config;

  _config = {
    rpcUrl: optionalEnv('RPC_URL', 'https://api.mainnet-beta.solana.com'),
    wsUrl: optionalEnv('WS_URL', 'wss://api.mainnet-beta.solana.com'),
    privateKey: optionalEnv('PRIVATE_KEY', ''),
    buyConfig: {
      amountSol: parseFloat(optionalEnv('BUY_AMOUNT_SOL', '0.1')),
      slippageBps: parseInt(optionalEnv('SLIPPAGE_BPS', '500'), 10),
      priorityFeeMicrolamports: parseInt(
        optionalEnv('PRIORITY_FEE_MICROLAMPORTS', '100000'),
        10,
      ),
    },
    minDevScore: parseFloat(optionalEnv('MIN_DEV_SCORE', '50')),
    maxTokensToTrack: parseInt(optionalEnv('MAX_TOKENS_TO_TRACK', '20'), 10),
    jupiterApiUrl: optionalEnv('JUPITER_API_URL', 'https://quote-api.jup.ag/v6'),
    dataDir: path.resolve(optionalEnv('DATA_DIR', './data')),
    logLevel: optionalEnv('LOG_LEVEL', 'info'),
    logFile: optionalEnv('LOG_FILE', 'logs/sniper.log'),
  };

  return _config;
}

// Well-known program IDs
export const PUMP_FUN_PROGRAM_ID = '6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBymvf77';
export const RAYDIUM_AMM_PROGRAM_ID = '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8';
export const TOKEN_PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
export const SYSTEM_PROGRAM_ID = '11111111111111111111111111111111';
export const SOL_MINT = 'So11111111111111111111111111111111111111112';

// Score thresholds
export const WIN_MARKET_CAP_USD = 100_000; // $100k peak = "win"
export const RUG_WINDOW_MS = 30 * 60 * 1000; // 30 min liquidity removed = rug

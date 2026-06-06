/**
 * server.ts
 * Express + WebSocket dashboard server for the Solana Sniper Bot.
 * Run with: ts-node src/server.ts
 */

import 'dotenv/config';
import express, { Request, Response } from 'express';
import http from 'http';
import path from 'path';
import fs from 'fs';
import { WebSocketServer, WebSocket } from 'ws';
import {
  loadWalletStore,
  addTrackedWallet,
  removeTrackedWallet,
  getLeaderboard,
} from './analyzer';
import { getConfig } from './config';
import { logger } from './logger';

// ─── Config ───────────────────────────────────────────────────────────────────

const PORT = parseInt(process.env.DASHBOARD_PORT ?? '3000', 10);
const PUBLIC_DIR = path.resolve(__dirname, '..', 'public');

// ─── In-memory activity log ───────────────────────────────────────────────────

export interface ActivityEvent {
  id: string;
  type: 'detected' | 'snipe' | 'error' | 'score_update' | 'info';
  message: string;
  timestamp: number;
  data?: Record<string, unknown>;
}

const activityLog: ActivityEvent[] = [];
const MAX_ACTIVITY = 500;

function pushActivity(event: Omit<ActivityEvent, 'id'>): ActivityEvent {
  const full: ActivityEvent = {
    ...event,
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
  };
  activityLog.unshift(full);
  if (activityLog.length > MAX_ACTIVITY) activityLog.length = MAX_ACTIVITY;
  broadcast({ type: 'activity', payload: full });
  return full;
}

// ─── WebSocket broadcast ──────────────────────────────────────────────────────

let wss: WebSocketServer;

function broadcast(msg: unknown): void {
  const text = JSON.stringify(msg);
  if (!wss) return;
  for (const client of wss.clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(text);
    }
  }
}

// ─── Daily stats ──────────────────────────────────────────────────────────────

interface DayStats {
  snipesToday: number;
  solSpentToday: number;
  pnlEstimate: number | null;
  date: string;
}

const todayKey = () => new Date().toISOString().slice(0, 10);

let dayStats: DayStats = {
  snipesToday: 0,
  solSpentToday: 0,
  pnlEstimate: null,
  date: todayKey(),
};

function resetDayIfNeeded(): void {
  if (dayStats.date !== todayKey()) {
    dayStats = {
      snipesToday: 0,
      solSpentToday: 0,
      pnlEstimate: null,
      date: todayKey(),
    };
  }
}

// ─── Express app ──────────────────────────────────────────────────────────────

const app = express();
app.use(express.json());
app.use(express.static(PUBLIC_DIR));

// GET /api/wallets
app.get('/api/wallets', (_req: Request, res: Response) => {
  const store = loadWalletStore();
  res.json({ wallets: getLeaderboard(store) });
});

// POST /api/wallets  { address, alias? }
app.post('/api/wallets', (req: Request, res: Response) => {
  const { address, alias } = req.body as { address?: string; alias?: string };
  if (!address || typeof address !== 'string') {
    res.status(400).json({ error: 'address is required' });
    return;
  }
  try {
    const store = loadWalletStore();
    const dev = addTrackedWallet(store, address.trim(), alias?.trim());
    pushActivity({
      type: 'info',
      message: `Wallet added: ${dev.alias ?? dev.address.slice(0, 8)}…`,
      timestamp: Date.now(),
      data: { address: dev.address, alias: dev.alias },
    });
    broadcast({ type: 'wallet_added', payload: dev });
    res.json({ wallet: dev });
  } catch (err) {
    res.status(400).json({ error: String(err) });
  }
});

// DELETE /api/wallets/:address
app.delete('/api/wallets/:address', (req: Request, res: Response) => {
  const { address } = req.params;
  const store = loadWalletStore();
  const removed = removeTrackedWallet(store, address);
  if (!removed) {
    res.status(404).json({ error: 'Wallet not found' });
    return;
  }
  pushActivity({
    type: 'info',
    message: `Wallet removed: ${address.slice(0, 8)}…`,
    timestamp: Date.now(),
    data: { address },
  });
  broadcast({ type: 'wallet_removed', payload: { address } });
  res.json({ success: true });
});

// GET /api/activity?limit=100
app.get('/api/activity', (req: Request, res: Response) => {
  resetDayIfNeeded();
  const limit = Math.min(
    parseInt(String(req.query.limit ?? '100'), 10),
    MAX_ACTIVITY,
  );
  res.json({ events: activityLog.slice(0, limit) });
});

// GET /api/config
app.get('/api/config', (_req: Request, res: Response) => {
  const cfg = getConfig();
  res.json({
    BUY_AMOUNT_SOL: cfg.buyConfig.amountSol,
    SLIPPAGE_BPS: cfg.buyConfig.slippageBps,
    MIN_DEV_SCORE: cfg.minDevScore,
    PRIORITY_FEE_MICROLAMPORTS: cfg.buyConfig.priorityFeeMicrolamports,
    MAX_TOKENS_TO_TRACK: cfg.maxTokensToTrack,
    LOG_LEVEL: cfg.logLevel,
    DATA_DIR: cfg.dataDir,
  });
});

// GET /api/stats
app.get('/api/stats', (_req: Request, res: Response) => {
  resetDayIfNeeded();
  res.json(dayStats);
});

// POST /api/config — writes back to .env file
app.post('/api/config', (req: Request, res: Response) => {
  const updates = req.body as Record<string, string | number>;
  const envPath = path.resolve(process.cwd(), '.env');
  try {
    let content = fs.existsSync(envPath) ? fs.readFileSync(envPath, 'utf-8') : '';
    for (const [key, val] of Object.entries(updates)) {
      const line = `${key}=${val}`;
      const re = new RegExp(`^${key}=.*$`, 'm');
      if (re.test(content)) {
        content = content.replace(re, line);
      } else {
        content += `\n${line}`;
      }
    }
    fs.writeFileSync(envPath, content);
    pushActivity({
      type: 'info',
      message: 'Config updated via dashboard',
      timestamp: Date.now(),
      data: updates as Record<string, unknown>,
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// SPA fallback
app.get('*', (_req: Request, res: Response) => {
  res.sendFile(path.join(PUBLIC_DIR, 'index.html'));
});

// ─── HTTP + WebSocket server ──────────────────────────────────────────────────

const server = http.createServer(app);
wss = new WebSocketServer({ server, path: '/ws' });

wss.on('connection', (ws: WebSocket) => {
  logger.info('Dashboard: WebSocket client connected');

  // Send full snapshot on connect
  const store = loadWalletStore();
  resetDayIfNeeded();
  ws.send(
    JSON.stringify({
      type: 'snapshot',
      payload: {
        wallets: getLeaderboard(store),
        activity: activityLog.slice(0, 50),
        stats: dayStats,
      },
    }),
  );

  ws.on('message', (raw) => {
    try {
      const msg = JSON.parse(raw.toString()) as { type: string };
      if (msg.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong', ts: Date.now() }));
      }
    } catch { /* ignore */ }
  });

  ws.on('close', () => logger.info('Dashboard: WebSocket client disconnected'));
  ws.on('error', (err) => logger.warn('Dashboard: WebSocket error', { err }));
});

// ─── Public event emitters (import from other modules) ───────────────────────

export function emitDetectedEvent(
  mint: string,
  devAddress: string,
  platform: string,
  name?: string,
  symbol?: string,
): void {
  const sym = symbol ? ` (${symbol})` : '';
  pushActivity({
    type: 'detected',
    message: `New token detected${sym} via ${platform} — dev ${devAddress.slice(0, 8)}…`,
    timestamp: Date.now(),
    data: { mint, devAddress, platform, name, symbol },
  });
  broadcast({ type: 'new_token', payload: { mint, devAddress, platform, name, symbol } });
}

export function emitSnipeEvent(
  mint: string,
  txSignature: string,
  amountSol: number,
  success: boolean,
  error?: string,
): void {
  resetDayIfNeeded();
  if (success) {
    dayStats.snipesToday++;
    dayStats.solSpentToday = Math.round((dayStats.solSpentToday + amountSol) * 1e9) / 1e9;
  }
  pushActivity({
    type: success ? 'snipe' : 'error',
    message: success
      ? `Snipe executed: ${mint.slice(0, 8)}… | ${amountSol} SOL | tx: ${txSignature.slice(0, 12)}…`
      : `Snipe failed: ${mint.slice(0, 8)}… — ${error ?? 'unknown error'}`,
    timestamp: Date.now(),
    data: { mint, txSignature, amountSol, success, error },
  });
  broadcast({ type: 'snipe', payload: { mint, txSignature, amountSol, success, error } });
  broadcast({ type: 'stats', payload: dayStats });
}

export function emitScoreUpdate(address: string, score: number, alias?: string): void {
  broadcast({ type: 'score_update', payload: { address, score, alias } });
}

// ─── Start ────────────────────────────────────────────────────────────────────

server.listen(PORT, () => {
  pushActivity({
    type: 'info',
    message: `SOL Sniper Dashboard started on port ${PORT}`,
    timestamp: Date.now(),
  });
  logger.info(`SOL Sniper Dashboard → http://localhost:${PORT}`);
});

process.on('SIGINT', () => { server.close(); process.exit(0); });
process.on('SIGTERM', () => { server.close(); process.exit(0); });

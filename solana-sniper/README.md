# Solana Sniper Bot

Tracks wallets of winning token developers and auto-buys new token deployments on pump.fun and Raydium.

## Setup

```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env: set RPC_URL, WS_URL, PRIVATE_KEY, BUY_AMOUNT_SOL, etc.

# 3. Build
npm run build
```

## CLI Usage

```bash
# Add a dev wallet to track
npx ts-node src/index.ts add-wallet <WALLET_ADDRESS> [optional-alias]

# Remove a wallet
npx ts-node src/index.ts remove-wallet <WALLET_ADDRESS>

# View leaderboard (devs ranked by score)
npx ts-node src/index.ts leaderboard

# Simulate a buy (dry-run, no real transaction)
npx ts-node src/index.ts simulate <TOKEN_MINT>

# Start the tracking daemon (default)
npx ts-node src/index.ts track

# Watch-only mode (detect but do not execute buys)
npx ts-node src/index.ts track --dry-run
```

Or after building:
```bash
node dist/index.js add-wallet <ADDRESS>
node dist/index.js leaderboard
node dist/index.js track
```

## Configuration (.env)

| Variable | Default | Description |
|---|---|---|
| `RPC_URL` | mainnet-beta | Solana HTTP RPC endpoint |
| `WS_URL` | mainnet-beta | Solana WebSocket endpoint |
| `PRIVATE_KEY` | _(empty)_ | Base-58 wallet private key. Leave empty for watch-only mode |
| `BUY_AMOUNT_SOL` | `0.1` | SOL to spend per snipe |
| `SLIPPAGE_BPS` | `500` | Slippage tolerance (500 = 5%) |
| `PRIORITY_FEE_MICROLAMPORTS` | `100000` | Priority fee for faster confirmation |
| `MIN_DEV_SCORE` | `50` | Minimum dev score (0–100) to auto-snipe |
| `MAX_TOKENS_TO_TRACK` | `20` | Max historical tokens stored per dev |
| `JUPITER_API_URL` | jup.ag/v6 | Jupiter swap API base URL |
| `LOG_LEVEL` | `info` | `debug` / `info` / `warn` / `error` |
| `LOG_FILE` | `logs/sniper.log` | Log file path |

## Dev Scoring Formula (0–100)

| Component | Weight |
|---|---|
| Win rate (tokens above $100K peak market cap) | +40 pts |
| Average peak market cap (log-scaled to $10M) | +30 pts |
| Rug rate penalty (liquidity removed within 30 min) | −20 pts |
| Recency bonus (active in last 7 days) | +10 pts |

## Architecture

```
index.ts        – CLI + daemon orchestration
tracker.ts      – WebSocket subscriptions + tx parsing for new token mints
sniper.ts       – Jupiter V6 quote → swap → confirm flow
analyzer.ts     – Dev scoring, wallet store persistence, market cap polling
config.ts       – .env parsing and program IDs
logger.ts       – Winston-based structured logging
types.ts        – Shared TypeScript interfaces
```

## Data

Wallet metadata and token history are persisted in `data/wallets.json`. Logs are written to `logs/sniper.log` (rotated at 10 MB, 5 files kept).

## Disclaimer

This software is for educational purposes only. Trading newly launched tokens carries extreme risk of total loss. Never invest more than you can afford to lose.

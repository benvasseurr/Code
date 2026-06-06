import winston from 'winston';
import path from 'path';
import fs from 'fs';

const LOG_DIR = path.dirname(process.env.LOG_FILE ?? 'logs/sniper.log');
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.printf(({ level, message, timestamp, ...meta }) => {
    const metaStr = Object.keys(meta).length ? ' ' + JSON.stringify(meta) : '';
    return `[${timestamp}] [${level.toUpperCase().padEnd(5)}] ${message}${metaStr}`;
  }),
);

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL ?? 'info',
  format: logFormat,
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        logFormat,
      ),
    }),
    new winston.transports.File({
      filename: process.env.LOG_FILE ?? 'logs/sniper.log',
      maxsize: 10 * 1024 * 1024, // 10 MB
      maxFiles: 5,
      tailable: true,
    }),
  ],
});

export function logBuy(mint: string, devAddress: string, amountSol: number, txSig?: string, error?: string): void {
  if (error) {
    logger.error('BUY FAILED', { mint, devAddress, amountSol, error });
  } else {
    logger.info('BUY EXECUTED', { mint, devAddress, amountSol, txSig });
  }
}

export function logNewToken(mint: string, devAddress: string, platform: string): void {
  logger.info('NEW TOKEN DETECTED', { mint, devAddress, platform });
}

export function logDevScore(address: string, score: number, alias?: string): void {
  logger.info('DEV SCORE UPDATED', { address, alias: alias ?? address.slice(0, 8), score });
}

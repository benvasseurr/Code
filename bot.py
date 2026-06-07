#!/usr/bin/env python3
"""
Congressional Trade Bot
=======================
Polls House and Senate stock-disclosure feeds, and mirrors every new trade
on your Webull account (paper or live — controlled by PAPER_TRADE in .env).

Usage:
    cp .env.example .env   # fill in credentials
    pip install -r requirements.txt
    python bot.py

The bot will ask for your Webull MFA code on first run, then loop forever.
Press Ctrl+C to stop.
"""

import logging
import os
import time

from dotenv import load_dotenv

load_dotenv()

from broker import WebullBroker
from db import TradeDatabase
from fetcher import get_all_disclosures

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s  %(levelname)-8s  %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('bot.log', encoding='utf-8'),
    ],
)
log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Config (from .env)
# ---------------------------------------------------------------------------
POLL_INTERVAL   = int(os.getenv('POLL_INTERVAL_SECONDS', '300'))
TRADE_AMOUNT    = float(os.getenv('TRADE_AMOUNT_USD', '1000'))
_raw_filter     = os.getenv('FILTER_MEMBERS', '')
MEMBER_FILTER   = [m.strip().lower() for m in _raw_filter.split(',') if m.strip()]

# Tickers to never trade (options, funds, foreign securities, etc.)
SKIP_TICKERS = {'--', 'N/A', '', 'CASH', 'SPY', 'QQQ'}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _member_allowed(member: str) -> bool:
    if not MEMBER_FILTER:
        return True
    return any(f in member.lower() for f in MEMBER_FILTER)


def _ticker_valid(ticker: str) -> bool:
    return bool(ticker) and ticker not in SKIP_TICKERS and ticker.isalpha()


# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------

def run(broker: WebullBroker, db: TradeDatabase):
    log.info(
        "Bot running — poll every %ds, $%.0f per trade, filter=%s",
        POLL_INTERVAL,
        TRADE_AMOUNT,
        MEMBER_FILTER or 'ALL members',
    )

    while True:
        log.info("Fetching disclosures …")
        disclosures = get_all_disclosures()
        log.info("  %d disclosures returned", len(disclosures))

        new_count = 0
        for trade in disclosures:
            if db.is_seen(trade['id']):
                continue

            member = trade['member']
            ticker = trade['ticker']
            action = 'BUY' if trade['type'] == 'buy' else 'SELL'

            # Always mark seen so we don't retry bad tickers on next poll
            db.mark_seen(trade['id'])

            if not _member_allowed(member):
                continue

            if not _ticker_valid(ticker):
                log.debug("Skipping non-equity ticker %r (%s)", ticker, member)
                continue

            log.info(
                "NEW TRADE ▶ %s %s by %s | amount: %s | disclosed: %s",
                action, ticker, member, trade['amount'], trade['disclosure_date'],
            )

            try:
                result = broker.place_market_order(ticker, action, TRADE_AMOUNT)
                db.log_order(
                    trade_id=trade['id'],
                    ticker=ticker,
                    action=action,
                    shares=result['shares'],
                    price=result['approx_price'],
                    paper=result['paper'],
                )
                new_count += 1
            except Exception as exc:
                log.error("Order failed (%s %s): %s", action, ticker, exc)

        log.info("  %d new trade(s) processed this cycle.", new_count)
        log.info("Sleeping %ds …\n", POLL_INTERVAL)
        time.sleep(POLL_INTERVAL)


def main():
    db     = TradeDatabase()
    broker = WebullBroker()
    broker.login()
    run(broker, db)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        log.info("Bot stopped by user.")

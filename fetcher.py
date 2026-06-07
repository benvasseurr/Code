"""
Fetches congressional trade disclosures from:
  - House Stock Watcher  (housestockwatcher.com/api)
  - Senate Stock Watcher (senatestockwatcher.com/api)

Both are free, no API key required.
Disclosures lag up to 45 days from the actual transaction date (STOCK Act requirement).
"""

import hashlib
import logging
import requests

log = logging.getLogger(__name__)

HOUSE_URL  = 'https://housestockwatcher.com/api'
SENATE_URL = 'https://senatestockwatcher.com/api'
HEADERS    = {'User-Agent': 'congressional-trade-bot/1.0'}
TIMEOUT    = 20


def _trade_id(source: str, trade: dict) -> str:
    """Stable, deterministic ID so the same disclosure is never executed twice."""
    key = ':'.join([
        source,
        trade.get('transaction_date', ''),
        trade.get('ticker', ''),
        trade.get('type', ''),
        trade.get('representative') or trade.get('senator', ''),
        trade.get('amount', ''),
    ])
    return hashlib.sha1(key.encode()).hexdigest()


def _normalise_type(raw: str) -> str:
    """Map disclosure text to 'buy' or 'sell'."""
    lower = raw.lower()
    if 'purchase' in lower:
        return 'buy'
    if 'sale' in lower or 'exchange' in lower:
        return 'sell'
    return 'unknown'


def _parse_house(rows: list) -> list[dict]:
    out = []
    for row in rows:
        trade_type = _normalise_type(row.get('type', ''))
        if trade_type == 'unknown':
            continue
        out.append({
            'id':               _trade_id('house', row),
            'source':           'house',
            'member':           row.get('representative', ''),
            'ticker':           (row.get('ticker') or '').strip().upper(),
            'type':             trade_type,
            'amount':           row.get('amount', ''),
            'transaction_date': row.get('transaction_date', ''),
            'disclosure_date':  row.get('disclosure_date', ''),
            'description':      row.get('asset_description', ''),
        })
    return out


def _parse_senate(rows: list) -> list[dict]:
    out = []
    for row in rows:
        trade_type = _normalise_type(row.get('type', ''))
        if trade_type == 'unknown':
            continue
        out.append({
            'id':               _trade_id('senate', row),
            'source':           'senate',
            'member':           row.get('senator', ''),
            'ticker':           (row.get('ticker') or '').strip().upper(),
            'type':             trade_type,
            'amount':           row.get('amount', ''),
            'transaction_date': row.get('transaction_date', ''),
            'disclosure_date':  row.get('disclosure_date', ''),
            'description':      row.get('asset_description', ''),
        })
    return out


def get_all_disclosures() -> list[dict]:
    """Return all currently published disclosures from both chambers."""
    trades = []

    for url, parser, label in [
        (HOUSE_URL, _parse_house, 'House'),
        (SENATE_URL, _parse_senate, 'Senate'),
    ]:
        try:
            resp = requests.get(url, headers=HEADERS, timeout=TIMEOUT)
            resp.raise_for_status()
            trades.extend(parser(resp.json()))
        except Exception as exc:
            log.error("%s API error: %s", label, exc)

    return trades

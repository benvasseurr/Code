"""
Webull broker integration using the unofficial webull Python library.
pip install webull

On first run the bot will prompt for the MFA code sent to your Webull email/phone.
Subsequent runs reuse the saved session (stored in ~/.webull/).

Set PAPER_TRADE=true in .env to simulate orders without spending real money.
"""

import logging
import math
import os

log = logging.getLogger(__name__)


class WebullBroker:
    def __init__(self):
        self.paper = os.getenv('PAPER_TRADE', 'true').lower() == 'true'
        self.email       = os.getenv('WEBULL_EMAIL', '')
        self.password    = os.getenv('WEBULL_PASSWORD', '')
        self.trading_pin = os.getenv('WEBULL_TRADING_PIN', '')

        if self.paper:
            from webull import paper_webull
            self._wb = paper_webull()
            log.info("Broker: PAPER TRADE mode (no real money)")
        else:
            from webull import webull
            self._wb = webull()
            log.info("Broker: LIVE TRADE mode")

    # ------------------------------------------------------------------
    # Auth
    # ------------------------------------------------------------------

    def login(self, mfa: str = None):
        if not mfa:
            mfa = input(
                "Enter the MFA code Webull sent to your email/phone: "
            ).strip()

        result = self._wb.login(
            username=self.email,
            password=self.password,
            mfa=mfa,
        )
        log.info("Webull login: %s", result)

        if not self.paper:
            self._wb.get_trade_token(password=self.trading_pin)
            log.info("Trade token acquired.")

    # ------------------------------------------------------------------
    # Market data
    # ------------------------------------------------------------------

    def get_price(self, ticker: str) -> float:
        quote = self._wb.get_quote(stock=ticker)
        # Try several fields in order of reliability
        for field in ('close', 'pPrice', 'open', 'preClose'):
            val = quote.get(field)
            if val:
                return float(val)
        raise ValueError(f"No price data returned for {ticker}: {quote}")

    # ------------------------------------------------------------------
    # Order placement
    # ------------------------------------------------------------------

    def place_market_order(self, ticker: str, action: str,
                           usd_amount: float) -> dict:
        """
        Buy or sell `usd_amount` dollars worth of `ticker` at market.
        action: 'BUY' or 'SELL'
        Returns a summary dict.
        """
        action = action.upper()
        price  = self.get_price(ticker)
        shares = max(1, math.floor(usd_amount / price))

        log.info(
            "%s %s %d share(s) @ ~$%.2f (≈$%.0f) [%s]",
            "PAPER" if self.paper else "LIVE",
            action, shares, price, shares * price,
            ticker,
        )

        if not self.paper:
            result = self._wb.place_order(
                stock=ticker,
                action=action,
                orderType='MKT',
                enforce='DAY',
                quant=shares,
            )
        else:
            result = self._wb.place_order(
                stock=ticker,
                action=action,
                orderType='MKT',
                enforce='DAY',
                quant=shares,
            )

        return {
            'ticker': ticker,
            'action': action,
            'shares': shares,
            'approx_price': price,
            'paper': self.paper,
            'raw': result,
        }

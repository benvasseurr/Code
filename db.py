import sqlite3
import os


DB_PATH = os.getenv('DB_PATH', 'trades.db')


class TradeDatabase:
    def __init__(self, path: str = DB_PATH):
        self.conn = sqlite3.connect(path, check_same_thread=False)
        self._init_schema()

    def _init_schema(self):
        self.conn.executescript('''
            CREATE TABLE IF NOT EXISTS seen_trades (
                id          TEXT PRIMARY KEY,
                created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            CREATE TABLE IF NOT EXISTS executed_orders (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                trade_id        TEXT NOT NULL,
                ticker          TEXT NOT NULL,
                action          TEXT NOT NULL,
                shares          INTEGER NOT NULL,
                approx_price    REAL,
                paper           INTEGER NOT NULL DEFAULT 1,
                created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        self.conn.commit()

    def is_seen(self, trade_id: str) -> bool:
        cur = self.conn.execute(
            'SELECT 1 FROM seen_trades WHERE id = ?', (trade_id,)
        )
        return cur.fetchone() is not None

    def mark_seen(self, trade_id: str):
        self.conn.execute(
            'INSERT OR IGNORE INTO seen_trades (id) VALUES (?)', (trade_id,)
        )
        self.conn.commit()

    def log_order(self, trade_id: str, ticker: str, action: str,
                  shares: int, price: float, paper: bool):
        self.conn.execute(
            '''INSERT INTO executed_orders
               (trade_id, ticker, action, shares, approx_price, paper)
               VALUES (?, ?, ?, ?, ?, ?)''',
            (trade_id, ticker, action, shares, price, int(paper))
        )
        self.conn.commit()

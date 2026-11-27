import sqlite3


def connect(path):
    conn = sqlite3.connect(path)
    conn.execute(
        """CREATE TABLE IF NOT EXISTS payments (
            payment_id TEXT NOT NULL,
            booked_on TEXT NOT NULL,
            payer TEXT NOT NULL,
            amount_cents INTEGER NOT NULL
        )"""
    )
    return conn

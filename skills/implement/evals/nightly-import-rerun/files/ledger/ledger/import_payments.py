import csv
import json
import shutil
import sys
from pathlib import Path

from ledger.db import connect


def parse_amount(text):
    euros, _, cents = text.strip().partition(".")
    return int(euros) * 100 + int((cents + "00")[:2])


def import_file(conn, path):
    count = 0
    with open(path, newline="") as handle:
        for row in csv.DictReader(handle):
            conn.execute(
                "INSERT INTO payments (payment_id, booked_on, payer, amount_cents) VALUES (?, ?, ?, ?)",
                (row["id"], row["date"], row["payer"], parse_amount(row["amount"])),
            )
            conn.commit()
            count += 1
    return count


def write_summary(conn, data_dir):
    total, rows = conn.execute("SELECT COALESCE(SUM(amount_cents), 0), COUNT(*) FROM payments").fetchone()
    with open(Path(data_dir) / "summary.json", "w") as handle:
        json.dump({"payments": rows, "total_cents": total}, handle)


def run(data_dir):
    data_dir = Path(data_dir)
    inbox, processed = data_dir / "inbox", data_dir / "processed"
    processed.mkdir(parents=True, exist_ok=True)
    conn = connect(data_dir / "ledger.db")
    imported = 0
    for path in sorted(inbox.glob("*.csv")):
        imported += import_file(conn, path)
        shutil.move(str(path), processed / path.name)
    write_summary(conn, data_dir)
    conn.close()
    return imported


if __name__ == "__main__":
    print(f"imported {run(sys.argv[1])} payments")

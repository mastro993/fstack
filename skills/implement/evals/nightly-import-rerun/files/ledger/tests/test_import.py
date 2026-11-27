import json
import tempfile
import unittest
from pathlib import Path

from ledger.db import connect
from ledger.import_payments import parse_amount, run

CSV = "id,date,payer,amount\nP1,2026-03-01,Ada,12.50\nP2,2026-03-01,Bob,3\n"


class ImportTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.data = Path(self.tmp.name)
        (self.data / "inbox").mkdir()
        (self.data / "inbox" / "2026-03-01.csv").write_text(CSV)

    def tearDown(self):
        self.tmp.cleanup()

    def test_amounts_become_cents(self):
        self.assertEqual([parse_amount(a) for a in ["12.50", "3", "0.5"]], [1250, 300, 50])

    def test_a_run_loads_the_file_and_moves_it(self):
        self.assertEqual(run(self.data), 2)
        self.assertTrue((self.data / "processed" / "2026-03-01.csv").exists())
        self.assertFalse((self.data / "inbox" / "2026-03-01.csv").exists())

    def test_the_summary_totals_every_payment(self):
        run(self.data)
        summary = json.loads((self.data / "summary.json").read_text())
        self.assertEqual(summary, {"payments": 2, "total_cents": 1550})

    def test_rows_land_in_the_ledger(self):
        run(self.data)
        conn = connect(self.data / "ledger.db")
        rows = conn.execute("SELECT payment_id, amount_cents FROM payments ORDER BY payment_id").fetchall()
        self.assertEqual(rows, [("P1", 1250), ("P2", 300)])

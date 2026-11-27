import unittest
from unittest import mock

from jobs import invoices


class InvoicesTest(unittest.TestCase):
    def test_sends_billable_invoices(self):
        sent = []
        count = invoices.run(
            [
                {"id": 1, "total_cents": 500, "email": "a@x.example"},
                {"id": 2, "total_cents": 0, "email": "b@x.example"},
            ],
            sent.append,
        )
        self.assertEqual(count, 1)
        self.assertEqual([invoice["id"] for invoice in sent], [1])

    def test_warns_about_empty_invoices(self):
        with mock.patch("jobs.invoices.log") as log:
            invoices.run([{"id": 7, "total_cents": 0, "email": "c@x.example"}], lambda invoice: None)
        log.assert_any_call("warn", "skipping invoice 7: nothing to bill")

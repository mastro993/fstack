import unittest
from datetime import datetime

from circulation import notify
from circulation.expiry import expire_stale_holds
from circulation.holds import Hold, HoldQueue


class ExpiryTest(unittest.TestCase):
    def setUp(self):
        notify.OUTBOX.clear()
        self.q = HoldQueue()
        self.q.place(Hold(1, 7, 100, datetime(2026, 3, 1)))
        self.q.place(Hold(2, 7, 101, datetime(2026, 3, 2)))
        self.q.mark_ready(7, datetime(2026, 3, 10))

    def test_uncollected_hold_expires_after_seven_days(self):
        self.assertEqual(expire_stale_holds(self.q, datetime(2026, 3, 18)), [1])
        self.assertEqual(self.q.get(1).status, "expired")

    def test_book_passes_to_next_patron(self):
        expire_stale_holds(self.q, datetime(2026, 3, 18))
        self.assertEqual(self.q.get(2).status, "ready")
        self.assertEqual([m["template"] for m in notify.OUTBOX], ["hold_ready", "hold_expired", "hold_ready"])

    def test_hold_within_pickup_window_stays_ready(self):
        self.assertEqual(expire_stale_holds(self.q, datetime(2026, 3, 16)), [])


if __name__ == "__main__":
    unittest.main()

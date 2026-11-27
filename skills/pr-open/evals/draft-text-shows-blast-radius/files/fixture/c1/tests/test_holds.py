import unittest
from datetime import datetime

from circulation import notify
from circulation.holds import Hold, HoldQueue


class HoldQueueTest(unittest.TestCase):
    def setUp(self):
        notify.OUTBOX.clear()

    def test_next_for_is_oldest_request(self):
        q = HoldQueue()
        q.place(Hold(1, 7, 100, datetime(2026, 3, 2)))
        q.place(Hold(2, 7, 101, datetime(2026, 3, 1)))
        self.assertEqual(q.next_for(7).id, 2)

    def test_mark_ready_notifies_next_patron(self):
        q = HoldQueue()
        q.place(Hold(1, 7, 100, datetime(2026, 3, 1)))
        q.mark_ready(7, datetime(2026, 3, 10))
        self.assertEqual(q.get(1).status, "ready")
        self.assertEqual(notify.OUTBOX[0]["template"], "hold_ready")
        self.assertEqual(notify.OUTBOX[0]["pickup_by"], datetime(2026, 3, 17))

    def test_collect_requires_ready(self):
        q = HoldQueue()
        q.place(Hold(1, 7, 100, datetime(2026, 3, 1)))
        with self.assertRaises(ValueError):
            q.collect(1)


if __name__ == "__main__":
    unittest.main()

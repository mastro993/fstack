import unittest
from datetime import datetime

from circulation.holds import Hold, HoldQueue


class HoldQueueTest(unittest.TestCase):
    def test_next_for_is_oldest_request(self):
        q = HoldQueue()
        q.place(Hold(1, 7, 100, datetime(2026, 3, 2)))
        q.place(Hold(2, 7, 101, datetime(2026, 3, 1)))
        self.assertEqual(q.next_for(7).id, 2)


if __name__ == "__main__":
    unittest.main()

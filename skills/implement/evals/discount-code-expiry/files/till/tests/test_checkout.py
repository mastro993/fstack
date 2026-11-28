import unittest

from till.checkout import checkout

CART = [{"price_cents": 1500, "qty": 2}, {"price_cents": 500, "qty": 1}]


class CheckoutTest(unittest.TestCase):
    def test_totals_the_cart(self):
        self.assertEqual(checkout(CART), {"total_cents": 3500, "error": None})

    def test_applies_a_code(self):
        self.assertEqual(checkout(CART, "STAFF50")["total_cents"], 1750)

    def test_unknown_code_keeps_the_full_total(self):
        self.assertEqual(
            checkout(CART, "NOPE"), {"total_cents": 3500, "error": "That code doesn't exist"}
        )

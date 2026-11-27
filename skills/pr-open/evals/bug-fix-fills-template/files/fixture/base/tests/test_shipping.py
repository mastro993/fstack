import unittest
from decimal import Decimal

from shop.shipping import shipping_cost


class ShippingCostTest(unittest.TestCase):
    def test_below_threshold_pays_flat_rate(self):
        self.assertEqual(shipping_cost(Decimal("49.99")), Decimal("4.90"))

    def test_above_threshold_is_free(self):
        self.assertEqual(shipping_cost(Decimal("80.00")), Decimal("0.00"))


if __name__ == "__main__":
    unittest.main()

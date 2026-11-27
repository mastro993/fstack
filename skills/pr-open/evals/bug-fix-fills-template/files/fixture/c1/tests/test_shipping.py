import unittest
from decimal import Decimal

from shop.quote_api import handle_quote
from shop.shipping import shipping_cost


class ShippingCostTest(unittest.TestCase):
    def test_below_threshold_pays_flat_rate(self):
        self.assertEqual(shipping_cost(Decimal("49.99")), Decimal("4.90"))

    def test_exactly_threshold_is_free(self):
        self.assertEqual(shipping_cost(Decimal("50.00")), Decimal("0.00"))

    def test_above_threshold_is_free(self):
        self.assertEqual(shipping_cost(Decimal("80.00")), Decimal("0.00"))

    def test_quote_at_threshold_has_free_shipping(self):
        quote = handle_quote({"items": [{"qty": 2, "unit_price": "25.00"}]})
        self.assertEqual(quote["shipping"], "0.00")
        self.assertEqual(quote["total"], "50.00")


if __name__ == "__main__":
    unittest.main()

from decimal import Decimal

FREE_SHIPPING_THRESHOLD = Decimal("50.00")
FLAT_RATE = Decimal("4.90")


def shipping_cost(subtotal: Decimal) -> Decimal:
    """Flat-rate shipping, free from the threshold up."""
    if subtotal >= FREE_SHIPPING_THRESHOLD:
        return Decimal("0.00")
    return FLAT_RATE

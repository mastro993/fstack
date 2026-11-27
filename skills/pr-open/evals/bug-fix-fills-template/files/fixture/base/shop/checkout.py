from decimal import Decimal, ROUND_HALF_UP

from shop.shipping import shipping_cost


def line_total(qty: int, unit_price: Decimal) -> Decimal:
    return (unit_price * qty).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def order_total(items: list[tuple[int, Decimal]]) -> dict:
    subtotal = sum((line_total(q, p) for q, p in items), Decimal("0.00"))
    shipping = shipping_cost(subtotal)
    return {"subtotal": subtotal, "shipping": shipping, "total": subtotal + shipping}

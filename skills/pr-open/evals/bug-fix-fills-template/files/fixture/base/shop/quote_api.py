"""POST /quote: the mobile app's price preview."""
from decimal import Decimal

from shop.checkout import order_total


def handle_quote(payload: dict) -> dict:
    items = [(i["qty"], Decimal(i["unit_price"])) for i in payload["items"]]
    totals = order_total(items)
    return {k: str(v) for k, v in totals.items()}

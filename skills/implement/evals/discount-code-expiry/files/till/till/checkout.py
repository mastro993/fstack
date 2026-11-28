from till import discounts


def checkout(cart, code=None):
    """Total a cart of {"price_cents", "qty"} lines, applying an optional discount code."""
    total = sum(line["price_cents"] * line["qty"] for line in cart)
    if code:
        try:
            total = discounts.apply_code(total, code)
        except discounts.UnknownCode:
            return {"total_cents": total, "error": "That code doesn't exist"}
    return {"total_cents": total, "error": None}

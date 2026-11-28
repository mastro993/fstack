"""Discount codes for checkout."""

_CODES = {
    "WELCOME10": 10,
    "SPRING25": 25,
    "STAFF50": 50,
}


class UnknownCode(ValueError):
    """The code isn't in the catalog."""


def _lookup(code):
    rate = _CODES.get(code.strip().upper())
    if rate is None:
        raise UnknownCode(f"unknown code: {code}")
    return rate


def apply_code(total_cents, code):
    """Return the total in cents after applying a discount code."""
    rate = _lookup(code)
    return total_cents - total_cents * rate // 100

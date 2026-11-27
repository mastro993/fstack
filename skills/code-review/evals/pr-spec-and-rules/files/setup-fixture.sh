#!/usr/bin/env bash
# shop/: PR #14 adds percentage coupons for issue #12 and misses or misreads three of its four
# criteria, computes the percentage with float math, and adds a handler that computes a discount
# itself, against CLAUDE.md. A float amount on a line carrying CLAUDE.md's display-only opt-out is
# allowed.
. "$(dirname "$0")/lib.sh"

new_repo shop
mkdir -p shop tests .github/workflows
cat > CLAUDE.md <<'EOF'
# Shop conventions

- Money is integer cents everywhere. Never use `float` for an amount. Display code may opt out with a `# money: display-only` comment on the line.
- Discount and coupon rules live in `shop/coupons.py`. HTTP handlers in `shop/api.py` call into it and never compute a discount themselves.
- Errors a customer can fix are `CheckoutError` subclasses from `shop/errors.py`.
EOF
cat > README.md <<'EOF'
# shop

Checkout service. `python3 -m unittest` runs the tests.
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python3 -m unittest discover -s tests -t .
EOF
cat > shop/__init__.py <<'EOF'
EOF
cat > shop/errors.py <<'EOF'
class CheckoutError(Exception):
    """An error the customer can fix; its message is shown to them."""


class CouponNotFound(CheckoutError):
    pass
EOF
cat > shop/orders.py <<'EOF'
from dataclasses import dataclass, field


@dataclass
class Order:
    id: str
    subtotal_cents: int
    coupon_codes: list[str] = field(default_factory=list)
    discount_cents: int = 0

    @property
    def total_cents(self) -> int:
        return self.subtotal_cents - self.discount_cents
EOF
cat > shop/coupons.py <<'EOF'
"""Coupon rules."""
from dataclasses import dataclass

from .errors import CouponNotFound


@dataclass(frozen=True)
class Coupon:
    code: str
    amount_off_cents: int


COUPONS = {
    "WELCOME5": Coupon("WELCOME5", 500),
}


def find(code: str) -> Coupon:
    try:
        return COUPONS[code.upper()]
    except KeyError:
        raise CouponNotFound(f"Unknown coupon {code}") from None


def discount_cents(coupon: Coupon, subtotal_cents: int) -> int:
    """What `coupon` takes off an order of `subtotal_cents`; never more than the subtotal."""
    return min(coupon.amount_off_cents, subtotal_cents)
EOF
cat > shop/api.py <<'EOF'
"""HTTP handlers."""
from . import coupons
from .orders import Order


def apply_coupon(order: Order, body: dict) -> dict:
    """POST /orders/<id>/coupon {"code": "..."}"""
    coupon = coupons.find(body["code"])
    order.discount_cents += coupons.discount_cents(coupon, order.total_cents)
    order.coupon_codes.append(coupon.code)
    return {"total_cents": order.total_cents}
EOF
cat > tests/__init__.py <<'EOF'
EOF
cat > tests/test_coupons.py <<'EOF'
import unittest

from shop import coupons
from shop.errors import CouponNotFound


class CouponTest(unittest.TestCase):
    def test_fixed_coupon(self):
        self.assertEqual(coupons.discount_cents(coupons.find("welcome5"), 2000), 500)

    def test_never_more_than_subtotal(self):
        self.assertEqual(coupons.discount_cents(coupons.find("WELCOME5"), 300), 300)

    def test_unknown(self):
        with self.assertRaises(CouponNotFound):
            coupons.find("NOPE")
EOF
commit "Checkout with fixed coupons"

git checkout -q -b feat/percentage-coupons
cat > shop/errors.py <<'EOF'
class CheckoutError(Exception):
    """An error the customer can fix; its message is shown to them."""


class CouponNotFound(CheckoutError):
    pass


class CouponExpired(CheckoutError):
    pass
EOF
cat > shop/coupons.py <<'EOF'
"""Coupon rules."""
from dataclasses import dataclass
from datetime import date

from .errors import CouponExpired, CouponNotFound


@dataclass(frozen=True)
class Coupon:
    code: str
    amount_off_cents: int = 0
    percent: int = 0
    max_off_cents: int | None = None
    expires_on: date | None = None


COUPONS = {
    "WELCOME5": Coupon("WELCOME5", amount_off_cents=500),
    "SPRING20": Coupon("SPRING20", percent=20, max_off_cents=3000, expires_on=date(2027, 4, 30)),
}


def find(code: str, today: date) -> Coupon:
    try:
        coupon = COUPONS[code.upper()]
    except KeyError:
        raise CouponNotFound(f"Unknown coupon {code}") from None
    if coupon.expires_on and coupon.expires_on <= today:
        raise CouponExpired(f"{coupon.code} expired on {coupon.expires_on:%d %b %Y}")
    return coupon


def discount_cents(coupon: Coupon, subtotal_cents: int) -> int:
    """What `coupon` takes off an order of `subtotal_cents`; never more than the subtotal."""
    if coupon.percent:
        off = round(subtotal_cents * coupon.percent / 100)
        if coupon.max_off_cents is not None:
            off = min(off, coupon.max_off_cents)
        return min(off, subtotal_cents)
    return min(coupon.amount_off_cents, subtotal_cents)


def describe(coupon: Coupon) -> str:
    """The coupon's label on the cart page."""
    if coupon.percent:
        return f"{coupon.percent}% off"
    return f"{coupon.amount_off_cents / 100:.2f} off"  # money: display-only
EOF
cat > shop/api.py <<'EOF'
"""HTTP handlers."""
from datetime import date

from . import coupons
from .orders import Order


def apply_coupon(order: Order, body: dict, today: date) -> dict:
    """POST /orders/<id>/coupon {"code": "..."}"""
    coupon = coupons.find(body["code"], today)
    order.discount_cents += coupons.discount_cents(coupon, order.total_cents)
    order.coupon_codes.append(coupon.code)
    return {"total_cents": order.total_cents, "label": coupons.describe(coupon)}


def preview_coupon(order: Order, body: dict, today: date) -> dict:
    """GET /orders/<id>/coupon-preview?code=... : the total the customer would pay."""
    coupon = coupons.find(body["code"], today)
    return {"total_cents": max(order.total_cents - coupon.amount_off_cents, 0)}
EOF
cat > tests/test_coupons.py <<'EOF'
import unittest
from datetime import date

from shop import coupons
from shop.errors import CouponExpired, CouponNotFound

TODAY = date(2027, 3, 1)


class CouponTest(unittest.TestCase):
    def test_fixed_coupon(self):
        self.assertEqual(coupons.discount_cents(coupons.find("welcome5", TODAY), 2000), 500)

    def test_never_more_than_subtotal(self):
        self.assertEqual(coupons.discount_cents(coupons.find("WELCOME5", TODAY), 300), 300)

    def test_unknown(self):
        with self.assertRaises(CouponNotFound):
            coupons.find("NOPE", TODAY)

    def test_percentage(self):
        self.assertEqual(coupons.discount_cents(coupons.find("SPRING20", TODAY), 10000), 2000)

    def test_percentage_is_capped(self):
        self.assertEqual(coupons.discount_cents(coupons.find("SPRING20", TODAY), 50000), 3000)

    def test_expired(self):
        with self.assertRaises(CouponExpired):
            coupons.find("SPRING20", date(2027, 5, 2))
EOF
commit "Percentage coupons with a cap and an expiry date" coupon-dev

publish shop 14=feat/percentage-coupons
cd "$ROOT"

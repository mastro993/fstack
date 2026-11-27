#!/usr/bin/env bash
# invoicer/: branch feat/csv-export, checked out and clean. Three bugs it introduces:
#   B1 paginate() becomes 0-based (docstring and tests updated) but web.list_invoices, untouched,
#      still passes 1-based pages, so the web UI never shows the first 20 invoices.
#   B2 export_csv() keeps `_written=set()` as a default argument, so a second export in the same
#      process skips every invoice the first one wrote.
#   B3 export_csv() sorts by paid_at, which is None for unpaid invoices: a mixed list raises
#      TypeError, though the function formats a missing paid_at, so it expects unpaid ones.
# Decoys the review should leave alone:
#   D1 money.format_cents() mishandles negative cents: pre-existing, and Invoice forbids negatives.
#   D2 report.days_overdue() can go negative, but its only caller passes overdue invoices.
#   D3 export.py imports os unused: ruff (F401) reports it in CI.
. "$(dirname "$0")/lib.sh"

new_repo invoicer
mkdir -p invoicer tests .github/workflows
cat > pyproject.toml <<'EOF'
[project]
name = "invoicer"
version = "0.3.0"
requires-python = ">=3.10"

[tool.ruff]
line-length = 110

[tool.ruff.lint]
select = ["E", "F"]
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ruff check .
      - run: python3 -m unittest discover -s tests -t .
EOF
cat > README.md <<'EOF'
# invoicer

Receivables for the back office: invoices, the overdue report, and the web UI's invoice list.
`python3 -m unittest discover -s tests -t .` runs the tests.
EOF
cat > invoicer/__init__.py <<'EOF'
EOF
cat > invoicer/models.py <<'EOF'
from dataclasses import dataclass
from datetime import date, datetime


@dataclass(frozen=True)
class Invoice:
    id: str
    customer: str
    cents: int
    due: date
    paid_at: datetime | None = None

    def __post_init__(self):
        if self.cents < 0:
            raise ValueError("invoice amounts are never negative; credit notes live elsewhere")
EOF
cat > invoicer/money.py <<'EOF'
def format_cents(cents: int) -> str:
    """Render cents as a decimal string: 1234 -> '12.34'."""
    units, rest = divmod(cents, 100)
    return f"{units}.{rest:02d}"
EOF
cat > invoicer/pagination.py <<'EOF'
def paginate(items, page, per_page):
    """Page `page` of `items`. Pages are 1-based: page 1 is the first `per_page` items."""
    if page < 1:
        raise ValueError("pages start at 1")
    start = (page - 1) * per_page
    return items[start:start + per_page]
EOF
cat > invoicer/report.py <<'EOF'
def overdue(invoices, today):
    """Unpaid invoices whose due date is strictly before `today`, oldest first."""
    late = [inv for inv in invoices if inv.paid_at is None and inv.due < today]
    return sorted(late, key=lambda inv: inv.due)
EOF
cat > invoicer/web.py <<'EOF'
"""Handlers for the back-office web UI."""
from .pagination import paginate
from .report import overdue

PER_PAGE = 20


def list_invoices(store, params):
    """GET /invoices?page=N: 20 invoices a page, newest first; page 1 when N is missing."""
    page = int(params.get("page", "1"))
    invoices = sorted(store.all(), key=lambda inv: inv.due, reverse=True)
    return {"page": page, "invoices": paginate(invoices, page, PER_PAGE)}


def overdue_report(store, today):
    """GET /reports/overdue"""
    return {"invoices": overdue(store.all(), today)}
EOF
cat > tests/__init__.py <<'EOF'
EOF
cat > tests/test_pagination.py <<'EOF'
import unittest

from invoicer.pagination import paginate


class PaginateTest(unittest.TestCase):
    def test_first_page(self):
        self.assertEqual(paginate([1, 2, 3, 4, 5], 1, 2), [1, 2])

    def test_last_partial_page(self):
        self.assertEqual(paginate([1, 2, 3, 4, 5], 3, 2), [5])

    def test_rejects_page_zero(self):
        with self.assertRaises(ValueError):
            paginate([1, 2], 0, 2)
EOF
cat > tests/test_report.py <<'EOF'
import unittest
from datetime import date, datetime

from invoicer.models import Invoice
from invoicer.report import overdue


class OverdueTest(unittest.TestCase):
    def test_unpaid_and_past_due_only(self):
        a = Invoice("A", "harbor", 100, date(2026, 1, 10))
        b = Invoice("B", "harbor", 100, date(2026, 1, 20), paid_at=datetime(2026, 1, 15))
        c = Invoice("C", "meadow", 100, date(2026, 2, 1))
        self.assertEqual(overdue([c, b, a], date(2026, 1, 25)), [a])
EOF
commit "Receivables: invoices, overdue report, web list"

git checkout -q -b feat/csv-export
cat > invoicer/pagination.py <<'EOF'
def paginate(items, page, per_page):
    """Page `page` of `items`. Pages are 0-based, like the export API: page 0 is the first
    `per_page` items."""
    if page < 0:
        raise ValueError("pages start at 0")
    start = page * per_page
    return items[start:start + per_page]
EOF
cat > tests/test_pagination.py <<'EOF'
import unittest

from invoicer.pagination import paginate


class PaginateTest(unittest.TestCase):
    def test_first_page(self):
        self.assertEqual(paginate([1, 2, 3, 4, 5], 0, 2), [1, 2])

    def test_last_partial_page(self):
        self.assertEqual(paginate([1, 2, 3, 4, 5], 2, 2), [5])

    def test_rejects_negative_page(self):
        with self.assertRaises(ValueError):
            paginate([1, 2], -1, 2)
EOF
commit "Make pagination 0-based like the export API"

cat > invoicer/export.py <<'EOF'
"""CSV export for the accounting system."""
import csv
import io
import os

from .money import format_cents
from .pagination import paginate

HEADER = ["invoice", "customer", "amount", "due", "paid_at"]


def export_csv(invoices, page=0, per_page=500, _written=set()):
    """One page of `invoices` as CSV, oldest payment first. An invoice listed twice in
    `invoices` is written once."""
    rows = []
    for inv in paginate(sorted(invoices, key=lambda inv: inv.paid_at), page, per_page):
        if inv.id in _written:
            continue
        _written.add(inv.id)
        paid = inv.paid_at.isoformat() if inv.paid_at else ""
        rows.append([inv.id, inv.customer, format_cents(inv.cents), inv.due.isoformat(), paid])
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(HEADER)
    writer.writerows(rows)
    return out.getvalue()
EOF
cat > tests/test_export.py <<'EOF'
import unittest
from datetime import date, datetime

from invoicer.export import export_csv
from invoicer.models import Invoice


class ExportTest(unittest.TestCase):
    def test_header_and_rows(self):
        a = Invoice("A1", "harbor", 1250, date(2026, 1, 31), paid_at=datetime(2026, 2, 1, 9, 0))
        lines = export_csv([a, a]).splitlines()
        self.assertEqual(lines, ["invoice,customer,amount,due,paid_at",
                                 "A1,harbor,12.50,2026-01-31,2026-02-01T09:00:00"])
EOF
commit "CSV export for accounting"

cat > invoicer/report.py <<'EOF'
def overdue(invoices, today):
    """Unpaid invoices whose due date is strictly before `today`, oldest first."""
    late = [inv for inv in invoices if inv.paid_at is None and inv.due < today]
    return sorted(late, key=lambda inv: inv.due)


def days_overdue(inv, today):
    """Whole days `inv` is past due; for invoices from overdue()."""
    return (today - inv.due).days


def overdue_lines(invoices, today):
    """One line per overdue invoice for the morning email: `<id> <customer> <n>d`."""
    return [f"{inv.id} {inv.customer} {days_overdue(inv, today)}d" for inv in overdue(invoices, today)]
EOF
cat >> tests/test_report.py <<'EOF'


class OverdueLinesTest(unittest.TestCase):
    def test_days_overdue(self):
        from invoicer.report import overdue_lines

        a = Invoice("A", "harbor", 100, date(2026, 1, 10))
        self.assertEqual(overdue_lines([a], date(2026, 1, 25)), ["A harbor 15d"])
EOF
commit "Days overdue in the morning email"
cd "$ROOT"

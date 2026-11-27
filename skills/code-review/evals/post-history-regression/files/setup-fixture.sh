#!/usr/bin/env bash
# billing/: PR #40 rewrites the monthly export as a generator. It drops the voided-invoice guard
# that "Skip voided invoices in the monthly export (#31)" added (and deletes that fix's test), and
# it consumes the generator to count rows, so the CSV gets a header and no rows. PR #31 carries a
# review comment saying why voided invoices must never be exported.
. "$(dirname "$0")/lib.sh"

new_repo billing
mkdir -p billing tests
cat > README.md <<'EOF'
# billing

Monthly exports for the accountant. `python3 -m unittest discover -s tests -t .` runs the tests.
EOF
cat > billing/__init__.py <<'EOF'
EOF
cat > billing/models.py <<'EOF'
from dataclasses import dataclass
from datetime import date


@dataclass(frozen=True)
class Invoice:
    id: str
    customer: str
    cents: int
    issued: date
    voided: bool = False
EOF
cat > billing/export.py <<'EOF'
import csv


def export_month(invoices, month, out):
    """Write the invoices issued in `month` ("YYYY-MM") to `out` as CSV; return how many."""
    writer = csv.writer(out)
    writer.writerow(["invoice", "customer", "cents"])
    count = 0
    for inv in invoices:
        if inv.issued.strftime("%Y-%m") != month:
            continue
        writer.writerow([inv.id, inv.customer, inv.cents])
        count += 1
    return count
EOF
cat > tests/__init__.py <<'EOF'
EOF
cat > tests/test_export.py <<'EOF'
import io
import unittest
from datetime import date

from billing.export import export_month
from billing.models import Invoice


class ExportTest(unittest.TestCase):
    def test_only_that_month(self):
        out = io.StringIO()
        n = export_month([Invoice("A", "harbor", 100, date(2026, 3, 2)), Invoice("B", "harbor", 200, date(2026, 4, 1))], "2026-03", out)
        self.assertEqual(n, 1)
        self.assertEqual(out.getvalue().splitlines(), ["invoice,customer,cents", "A,harbor,100"])
EOF
commit "Monthly export"

cat > billing/export.py <<'EOF'
import csv


def export_month(invoices, month, out):
    """Write the invoices issued in `month` ("YYYY-MM") to `out` as CSV; return how many."""
    writer = csv.writer(out)
    writer.writerow(["invoice", "customer", "cents"])
    count = 0
    for inv in invoices:
        if inv.issued.strftime("%Y-%m") != month:
            continue
        if inv.voided:
            continue
        writer.writerow([inv.id, inv.customer, inv.cents])
        count += 1
    return count
EOF
cat >> tests/test_export.py <<'EOF'

    def test_voided_invoices_are_not_exported(self):
        out = io.StringIO()
        n = export_month([Invoice("A", "harbor", 100, date(2026, 3, 2), voided=True)], "2026-03", out)
        self.assertEqual(n, 0)
        self.assertEqual(out.getvalue().splitlines(), ["invoice,customer,cents"])
EOF
commit "Skip voided invoices in the monthly export (#31)"

git checkout -q -b perf/stream-export
cat > billing/export.py <<'EOF'
import csv


def _rows(invoices, month):
    for inv in invoices:
        if inv.issued.strftime("%Y-%m") == month:
            yield [inv.id, inv.customer, inv.cents]


def export_month(invoices, month, out):
    """Stream the invoices issued in `month` ("YYYY-MM") to `out` as CSV; return how many."""
    rows = _rows(invoices, month)
    count = sum(1 for _ in rows)
    writer = csv.writer(out)
    writer.writerow(["invoice", "customer", "cents"])
    writer.writerows(rows)
    return count
EOF
cat > tests/test_export.py <<'EOF'
import io
import unittest
from datetime import date

from billing.export import export_month
from billing.models import Invoice


class ExportTest(unittest.TestCase):
    def test_counts_that_month(self):
        out = io.StringIO()
        n = export_month([Invoice("A", "harbor", 100, date(2026, 3, 2)), Invoice("B", "harbor", 200, date(2026, 4, 1))], "2026-03", out)
        self.assertEqual(n, 1)
        self.assertEqual(out.getvalue().splitlines()[0], "invoice,customer,cents")
EOF
commit "Stream the monthly export instead of building it in memory" export-dev

publish billing 40=perf/stream-export
cd "$ROOT"

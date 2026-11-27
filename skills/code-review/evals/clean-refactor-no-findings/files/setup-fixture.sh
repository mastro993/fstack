#!/usr/bin/env bash
# units/: branch refactor/parse-duration, checked out and clean. It extracts duplicated duration
# parsing from two call sites into one tested function, behavior unchanged. Nothing to report.
. "$(dirname "$0")/lib.sh"

new_repo units
mkdir -p units tests
cat > README.md <<'EOF'
# units

Duration settings for the job runner. `python3 -m unittest discover -s tests -t .` runs the tests.
EOF
cat > units/__init__.py <<'EOF'
EOF
cat > units/jobs.py <<'EOF'
import re


def job_timeout_seconds(setting):
    """A job timeout like "90s", "15m" or "2h", in seconds."""
    m = re.fullmatch(r"(\d+)([smh])", setting.strip())
    if not m:
        raise ValueError(f"bad duration: {setting!r}")
    return int(m.group(1)) * {"s": 1, "m": 60, "h": 3600}[m.group(2)]


def retry_delay_seconds(setting):
    """A retry delay like "30s" or "5m", in seconds."""
    m = re.fullmatch(r"(\d+)([smh])", setting.strip())
    if not m:
        raise ValueError(f"bad duration: {setting!r}")
    return int(m.group(1)) * {"s": 1, "m": 60, "h": 3600}[m.group(2)]
EOF
cat > tests/__init__.py <<'EOF'
EOF
cat > tests/test_jobs.py <<'EOF'
import unittest

from units.jobs import job_timeout_seconds, retry_delay_seconds


class JobsTest(unittest.TestCase):
    def test_timeout(self):
        self.assertEqual(job_timeout_seconds("15m"), 900)

    def test_retry(self):
        self.assertEqual(retry_delay_seconds(" 30s "), 30)

    def test_bad(self):
        with self.assertRaises(ValueError):
            job_timeout_seconds("15 minutes")
EOF
commit "Job timeouts and retry delays"

git checkout -q -b refactor/parse-duration
cat > units/duration.py <<'EOF'
import re

_UNITS = {"s": 1, "m": 60, "h": 3600}


def parse_duration(setting):
    """A duration like "90s", "15m" or "2h", in seconds. Surrounding spaces are ignored."""
    m = re.fullmatch(r"(\d+)([smh])", setting.strip())
    if not m:
        raise ValueError(f"bad duration: {setting!r}")
    return int(m.group(1)) * _UNITS[m.group(2)]
EOF
cat > units/jobs.py <<'EOF'
from .duration import parse_duration


def job_timeout_seconds(setting):
    """A job timeout like "90s", "15m" or "2h", in seconds."""
    return parse_duration(setting)


def retry_delay_seconds(setting):
    """A retry delay like "30s" or "5m", in seconds."""
    return parse_duration(setting)
EOF
cat > tests/test_duration.py <<'EOF'
import unittest

from units.duration import parse_duration


class ParseDurationTest(unittest.TestCase):
    def test_units(self):
        self.assertEqual([parse_duration("90s"), parse_duration("15m"), parse_duration("2h")], [90, 900, 7200])

    def test_spaces_ignored(self):
        self.assertEqual(parse_duration(" 5m "), 300)

    def test_rejects_other_forms(self):
        for bad in ["15 minutes", "1.5h", "-5s", "", "10"]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                parse_duration(bad)
EOF
commit "Extract parse_duration from the job settings"
cd "$ROOT"

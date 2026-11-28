import contextlib
import io
import os
import tempfile
import unittest

from tally.__main__ import main

CSV = "2026-03-02,atlas,3.5\n2026-03-02,birch,2\n2026-03-03,atlas,4\n"


class ReportTest(unittest.TestCase):
    def setUp(self):
        fd, self.path = tempfile.mkstemp(suffix=".csv")
        with os.fdopen(fd, "w") as f:
            f.write(CSV)
        self.addCleanup(os.remove, self.path)

    def test_prints_hours_per_project_and_total(self):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            main(["report", self.path])
        self.assertEqual(
            out.getvalue(),
            "atlas     7.5\nbirch     2.0\nTotal     9.5\n",
        )

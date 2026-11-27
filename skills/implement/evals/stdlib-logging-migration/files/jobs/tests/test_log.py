import io
import unittest
from contextlib import redirect_stderr

from jobs.log import log


class LogTest(unittest.TestCase):
    def test_prefixes_the_level(self):
        err = io.StringIO()
        with redirect_stderr(err):
            log("warn", "disk almost full")
        self.assertEqual(err.getvalue(), "[WARN] disk almost full\n")

    def test_rejects_unknown_levels(self):
        with self.assertRaises(ValueError):
            log("loud", "hello")

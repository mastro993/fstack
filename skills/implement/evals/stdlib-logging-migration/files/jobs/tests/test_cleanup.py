import os
import tempfile
import unittest

from jobs import cleanup


class CleanupTest(unittest.TestCase):
    def test_removes_only_files_older_than_thirty_days(self):
        with tempfile.TemporaryDirectory() as directory:
            old = os.path.join(directory, "old.csv")
            new = os.path.join(directory, "new.csv")
            for path in (old, new):
                open(path, "w").close()
            now = os.path.getmtime(new)
            os.utime(old, (now - 31 * 24 * 3600, now - 31 * 24 * 3600))
            self.assertEqual(cleanup.run(directory, now=now), 1)
            self.assertEqual(os.listdir(directory), ["new.csv"])

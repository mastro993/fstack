import unittest

from jobs.retry import with_retries


class RetryTest(unittest.TestCase):
    def test_returns_the_first_success(self):
        calls = []

        def flaky():
            calls.append(1)
            if len(calls) < 2:
                raise RuntimeError("boom")
            return "ok"

        self.assertEqual(with_retries(flaky, sleep=lambda seconds: None), "ok")
        self.assertEqual(len(calls), 2)

    def test_raises_after_the_last_attempt(self):
        def broken():
            raise RuntimeError("down")

        with self.assertRaises(RuntimeError):
            with_retries(broken, attempts=2, sleep=lambda seconds: None)

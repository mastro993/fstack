import unittest
from unittest import mock

from till import discounts


class ApplyCodeTest(unittest.TestCase):
    def test_looks_up_the_code(self):
        with mock.patch.object(discounts, "_lookup", return_value=10) as lookup:
            discounts.apply_code(1000, "WELCOME10")
        lookup.assert_called_once_with("WELCOME10")

    def test_applies_the_rate(self):
        with mock.patch.dict(discounts._CODES, {"TEST20": 20}):
            self.assertEqual(discounts.apply_code(1000, "TEST20"), 800)

    def test_unknown_code_message(self):
        with self.assertRaises(ValueError) as ctx:
            discounts.apply_code(1000, "NOPE")
        self.assertEqual(str(ctx.exception), "unknown code: NOPE")

    def test_codes_ignore_case_and_spaces(self):
        self.assertEqual(discounts.apply_code(1000, " welcome10 "), 900)

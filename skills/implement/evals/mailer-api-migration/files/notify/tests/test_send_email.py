import unittest

from notify.mail import send_email
from tests.fakes import install_recorder


class SendEmailTest(unittest.TestCase):
    def test_a_single_address_becomes_a_one_item_list(self):
        transport = install_recorder()
        send_email("a@x.example", "s", "b")
        self.assertEqual(transport.sent[0][1].to, ("a@x.example",))

    def test_an_empty_recipient_list_is_refused(self):
        install_recorder()
        with self.assertRaises(ValueError):
            send_email([], "s", "b")

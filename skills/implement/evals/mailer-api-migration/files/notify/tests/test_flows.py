import unittest
from unittest import mock

from notify import billing, digest, invites, password, signup
from tests.fakes import install_recorder

USER = {"email": "ada@x.example", "name": "Ada"}


class FlowsTest(unittest.TestCase):
    def test_welcome_greets_the_user_by_name(self):
        transport = install_recorder()
        signup.welcome(USER)
        message = transport.sent[0][1]
        self.assertEqual(message.to, ("ada@x.example",))
        self.assertIn("Hi Ada", message.body)

    def test_reset_link_carries_the_token(self):
        with mock.patch("notify.password.send_email") as send:
            password.reset_link(USER, "tok123")
        send.assert_called_once()
        self.assertIn("token=tok123", send.call_args.args[2])

    def test_receipt_is_html_with_the_amount(self):
        transport = install_recorder()
        billing.receipt(USER, 1250)
        message = transport.sent[0][1]
        self.assertTrue(message.html)
        self.assertIn("12.50 EUR", message.body)

    def test_finance_gets_both_addresses(self):
        transport = install_recorder()
        billing.notify_finance(500)
        self.assertEqual(transport.sent[0][1].to, ("finance@notify.example", "audit@notify.example"))

    def test_digest_lists_each_item(self):
        transport = install_recorder()
        digest.weekly_digest(USER, ["a", "b"])
        self.assertIn("<li>a</li><li>b</li>", transport.sent[0][1].body)

    def test_invite_is_tagged(self):
        transport = install_recorder()
        invites.invite(USER, "bob@x.example")
        self.assertEqual(transport.sent[0][1].tags, ("invite",))

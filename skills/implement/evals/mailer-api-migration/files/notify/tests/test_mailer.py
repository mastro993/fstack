import unittest

from notify.mailer import Mailer, Message
from tests.fakes import RecordingTransport


class MailerTest(unittest.TestCase):
    def test_sends_from_the_configured_sender(self):
        transport = RecordingTransport()
        Mailer(transport, sender="me@x.example").send(Message(to=("a@x.example",), subject="s", body="b"))
        self.assertEqual(transport.sent[0][0], "me@x.example")

    def test_a_message_without_recipients_is_refused(self):
        with self.assertRaises(ValueError):
            Mailer(RecordingTransport()).send(Message(to=(), subject="s", body="b"))

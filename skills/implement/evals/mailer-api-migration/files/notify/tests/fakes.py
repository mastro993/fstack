from notify.mailer import Mailer, set_default_mailer


class RecordingTransport:
    def __init__(self):
        self.sent = []

    def deliver(self, sender, message):
        self.sent.append((sender, message))
        return f"id-{len(self.sent)}"


def install_recorder():
    transport = RecordingTransport()
    set_default_mailer(Mailer(transport))
    return transport

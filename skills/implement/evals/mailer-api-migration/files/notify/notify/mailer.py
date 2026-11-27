from dataclasses import dataclass, field


@dataclass(frozen=True)
class Message:
    to: tuple[str, ...]
    subject: str
    body: str
    html: bool = False
    tags: tuple[str, ...] = field(default=())


class Mailer:
    def __init__(self, transport, sender="no-reply@notify.example"):
        self.transport = transport
        self.sender = sender

    def send(self, message: Message) -> str:
        if not message.to:
            raise ValueError("a message needs at least one recipient")
        return self.transport.deliver(self.sender, message)


class _NullTransport:
    def deliver(self, sender, message):
        return "dropped"


_default = Mailer(_NullTransport())


def default_mailer() -> Mailer:
    return _default


def set_default_mailer(mailer: Mailer) -> None:
    global _default
    _default = mailer

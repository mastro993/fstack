"""Old mail helper, kept until every caller moves to Mailer.send."""

from notify.mailer import Message, default_mailer


def send_email(to, subject, body, html=False):
    if isinstance(to, str):
        to = [to]
    if not to:
        raise ValueError("no recipient")
    return default_mailer().send(Message(to=tuple(to), subject=subject, body=body, html=html))

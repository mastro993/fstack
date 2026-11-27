"""Patron notifications. OUTBOX is drained by the mailer every minute."""
OUTBOX: list[dict] = []


def send(patron_id: int, template: str, **data) -> None:
    OUTBOX.append({"patron_id": patron_id, "template": template, **data})

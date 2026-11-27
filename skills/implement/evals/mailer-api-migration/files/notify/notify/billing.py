from notify import mail


def receipt(user, amount_cents):
    body = f"<p>We received {amount_cents / 100:.2f} EUR. Thank you!</p>"
    return mail.send_email(user["email"], "Your receipt", body, html=True)


def payment_failed(user):
    return mail.send_email(user["email"], "Payment failed", "Please update your card.")


def notify_finance(amount_cents):
    return mail.send_email(["finance@notify.example", "audit@notify.example"], "Payment", f"{amount_cents}")

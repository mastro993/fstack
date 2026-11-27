from notify.mail import send_email


def weekly_digest(user, items):
    lines = "".join(f"<li>{item}</li>" for item in items)
    return send_email(user["email"], "Your week", f"<ul>{lines}</ul>", True)

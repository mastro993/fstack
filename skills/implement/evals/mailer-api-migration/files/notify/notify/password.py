from notify.mail import send_email


def reset_link(user, token):
    url = f"https://app.example/reset?token={token}"
    return send_email(user["email"], "Reset your password", f"Open {url} within an hour.")


def password_changed(user):
    return send_email(user["email"], "Your password changed", "If this wasn't you, contact support.")

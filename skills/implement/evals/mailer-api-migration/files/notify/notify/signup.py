from notify.mail import send_email


def welcome(user):
    return send_email(user["email"], "Welcome aboard", f"Hi {user['name']}, thanks for signing up.")

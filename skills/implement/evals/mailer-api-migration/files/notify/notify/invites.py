from notify.mailer import Message, default_mailer


def invite(inviter, email):
    message = Message(to=(email,), subject=f"{inviter['name']} invited you", body="Join the team.", tags=("invite",))
    return default_mailer().send(message)

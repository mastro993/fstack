from notify.mail import send_email


def ops_alert(recipients, text):
    return send_email(recipients, "[ops] alert", text)

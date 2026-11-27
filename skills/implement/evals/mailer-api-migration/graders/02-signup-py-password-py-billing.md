---
type: llm
focus: trace
weight: 1
---

signup.py, password.py, billing.py, digest.py, and alerts.py each send through Mailer.send (e.g. default_mailer().send(Message(...))) with every former send_email call migrated, and html=True is preserved for receipt and weekly_digest.

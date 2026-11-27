from jobs.log import log


def run(invoices, send):
    log("info", "invoice run starting")
    sent = 0
    for invoice in invoices:
        if invoice["total_cents"] <= 0:
            log("warn", f"skipping invoice {invoice['id']}: nothing to bill")
            continue
        if not invoice.get("email"):
            log("error", f"invoice {invoice['id']} has no billing email")
            continue
        send(invoice)
        sent += 1
        log("debug", f"sent invoice {invoice['id']}")
    log("info", f"invoice run done: {sent} sent")
    return sent

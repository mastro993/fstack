from jobs.log import log


def run(customers, send, today):
    log("info", "reminder run starting")
    for customer in customers:
        if customer.get("opted_out"):
            log("debug", f"{customer['id']} opted out")
            continue
        overdue = [i for i in customer["invoices"] if i["due"] < today]
        if not overdue:
            continue
        if len(overdue) > 3:
            log("warn", f"{customer['id']} has {len(overdue)} overdue invoices")
        send(customer, overdue)
    log("info", "reminder run done")

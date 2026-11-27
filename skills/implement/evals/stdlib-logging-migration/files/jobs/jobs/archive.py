from jobs.log import log


def run(store, before):
    old = store.older_than(before)
    log("info", f"archiving {len(old)} records")
    for record in old:
        store.archive(record)
    if len(old) > 1000:
        log("warn", "large archive batch; consider running it nightly")
    log("debug", "archive done")
    return len(old)

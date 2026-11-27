import csv

from jobs.log import log


def run(rows, path):
    if not rows:
        log("warn", "nothing to export")
        return 0
    try:
        with open(path, "w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
    except OSError as error:
        log("fatal", f"could not write {path}: {error}")
        raise
    log("info", "exported %d rows to %s" % (len(rows), path))
    return len(rows)

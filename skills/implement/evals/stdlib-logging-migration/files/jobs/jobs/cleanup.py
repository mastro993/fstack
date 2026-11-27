import os
import time

from jobs.log import log

MAX_AGE_SECONDS = 30 * 24 * 3600


def run(directory, now=None):
    now = now or time.time()
    removed = 0
    for name in sorted(os.listdir(directory)):
        path = os.path.join(directory, name)
        if now - os.path.getmtime(path) > MAX_AGE_SECONDS:
            os.remove(path)
            removed += 1
            log(level="debug", message=f"removed {path}")
    log("info", f"cleanup removed {removed} files from {directory}")
    return removed

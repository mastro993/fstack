"""Scheduled jobs, run from cron by name: python3 jobs.py <name>."""
import sys
from datetime import datetime

from circulation.expiry import expire_stale_holds
from reports.circulation_report import nightly_summary

JOBS = {
    "nightly_report": lambda queue: print(nightly_summary(queue)),
    "expire_holds": lambda queue: expire_stale_holds(queue, datetime.now()),
}

if __name__ == "__main__":
    from circulation.holds import HoldQueue
    JOBS[sys.argv[1]](HoldQueue())

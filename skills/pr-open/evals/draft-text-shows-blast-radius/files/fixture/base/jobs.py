"""Scheduled jobs, run from cron by name: python3 jobs.py <name>."""
import sys

from reports.circulation_report import nightly_summary

JOBS = {
    "nightly_report": lambda queue: print(nightly_summary(queue)),
}

if __name__ == "__main__":
    from circulation.holds import HoldQueue
    JOBS[sys.argv[1]](HoldQueue())

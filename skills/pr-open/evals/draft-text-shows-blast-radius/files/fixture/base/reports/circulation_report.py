"""Nightly circulation report, emailed to branch managers."""
from circulation.holds import HoldQueue


def open_holds(queue: HoldQueue) -> int:
    return sum(1 for h in queue.holds if h.status == "requested")


def nightly_summary(queue: HoldQueue) -> str:
    return f"Open holds: {open_holds(queue)}"

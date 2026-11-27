from datetime import datetime, timedelta

from circulation import notify
from circulation.holds import HoldQueue
from circulation.settings import HOLD_PICKUP_DAYS


def expire_stale_holds(queue: HoldQueue, now: datetime) -> list[int]:
    """Expire ready holds nobody collected in time and pass each book to the next patron in line."""
    expired = []
    for hold in queue.holds:
        if hold.status == "ready" and now - hold.ready_at > timedelta(days=HOLD_PICKUP_DAYS):
            hold.status = "expired"
            notify.send(hold.patron_id, "hold_expired")
            queue.mark_ready(hold.book_id, now)
            expired.append(hold.id)
    return expired

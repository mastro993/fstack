from dataclasses import dataclass
from datetime import datetime, timedelta

from circulation import notify
from circulation.settings import HOLD_PICKUP_DAYS


@dataclass
class Hold:
    id: int
    book_id: int
    patron_id: int
    placed_at: datetime
    status: str = "requested"  # requested | ready | collected | expired
    ready_at: datetime | None = None


class HoldQueue:
    def __init__(self) -> None:
        self.holds: list[Hold] = []

    def place(self, hold: Hold) -> None:
        self.holds.append(hold)

    def get(self, hold_id: int) -> Hold:
        return next(h for h in self.holds if h.id == hold_id)

    def next_for(self, book_id: int) -> Hold | None:
        waiting = [h for h in self.holds if h.book_id == book_id and h.status == "requested"]
        return min(waiting, key=lambda h: h.placed_at, default=None)

    def mark_ready(self, book_id: int, now: datetime) -> Hold | None:
        """The book is back on the hold shelf: the next patron in line has HOLD_PICKUP_DAYS to collect it."""
        hold = self.next_for(book_id)
        if hold:
            hold.status, hold.ready_at = "ready", now
            notify.send(hold.patron_id, "hold_ready", pickup_by=now + timedelta(days=HOLD_PICKUP_DAYS))
        return hold

    def collect(self, hold_id: int) -> None:
        hold = self.get(hold_id)
        if hold.status != "ready":
            raise ValueError(f"hold {hold_id} is {hold.status}, not ready")
        hold.status = "collected"

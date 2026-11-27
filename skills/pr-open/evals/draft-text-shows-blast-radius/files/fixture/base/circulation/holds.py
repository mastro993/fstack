from dataclasses import dataclass
from datetime import datetime


@dataclass
class Hold:
    id: int
    book_id: int
    patron_id: int
    placed_at: datetime
    status: str = "requested"  # requested | collected


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

    def collect(self, hold_id: int) -> None:
        self.get(hold_id).status = "collected"

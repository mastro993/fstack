"""Front-desk actions, called by the staff app."""
from circulation.holds import HoldQueue


def hand_over_hold(queue: HoldQueue, hold_id: int) -> str:
    queue.collect(hold_id)
    return "handed over"

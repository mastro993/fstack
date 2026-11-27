import time

from jobs.log import log


def with_retries(action, attempts=3, delay=1.0, sleep=time.sleep):
    for attempt in range(1, attempts + 1):
        try:
            return action()
        except Exception as error:
            last = attempt == attempts
            log("error" if last else "warn", f"attempt {attempt}/{attempts} failed: {error}")
            if last:
                raise
            sleep(delay * attempt)

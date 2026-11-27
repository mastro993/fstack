import sys

LEVELS = ("debug", "info", "warn", "error", "fatal")


def log(level, message):
    if level not in LEVELS:
        raise ValueError(f"unknown log level {level!r}")
    print(f"[{level.upper()}] {message}", file=sys.stderr)

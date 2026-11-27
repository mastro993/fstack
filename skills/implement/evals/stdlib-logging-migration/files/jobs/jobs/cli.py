import sys

from jobs import cleanup


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) == 2 and argv[0] == "cleanup":
        cleanup.run(argv[1])
        return 0
    print("usage: python3 -m jobs.cli cleanup <dir>", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())

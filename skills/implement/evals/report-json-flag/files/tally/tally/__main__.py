import argparse
import sys

from tally.loader import CsvLoader
from tally.service import ReportService


def main(argv=None):
    parser = argparse.ArgumentParser(prog="tally")
    commands = parser.add_subparsers(dest="command", required=True)
    report = commands.add_parser("report", help="hours per project")
    report.add_argument("path")
    args = parser.parse_args(argv)
    print(ReportService(CsvLoader()).render(args.path))
    return 0


if __name__ == "__main__":
    sys.exit(main())

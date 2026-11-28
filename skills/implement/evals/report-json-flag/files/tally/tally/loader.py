import csv
from dataclasses import dataclass


@dataclass(frozen=True)
class Entry:
    date: str
    project: str
    hours: float


class CsvLoader:
    def load(self, path):
        with open(path, newline="") as f:
            return [Entry(row[0], row[1], float(row[2])) for row in csv.reader(f) if row]

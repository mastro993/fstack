from tally.formatting import TextFormatter
from tally.summary import summarize


class ReportService:
    def __init__(self, loader):
        self.loader = loader
        self.formatter = TextFormatter()

    def render(self, path):
        entries = self.loader.load(path)
        return self.formatter.format(summarize(entries))

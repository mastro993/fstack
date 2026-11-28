from abc import ABC, abstractmethod


class Formatter(ABC):
    @abstractmethod
    def format(self, summary):
        ...


class TextFormatter(Formatter):
    def format(self, summary):
        width = max([len(name) for name, _ in summary["projects"]] + [5])
        lines = [f"{name:<{width}}  {hours:6.1f}" for name, hours in summary["projects"]]
        lines.append(f"{'Total':<{width}}  {summary['total']:6.1f}")
        return "\n".join(lines)

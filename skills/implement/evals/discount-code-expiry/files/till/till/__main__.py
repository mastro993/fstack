import json
import sys

from till.checkout import checkout


def main(argv):
    with open(argv[0]) as f:
        cart = json.load(f)
    result = checkout(cart, argv[1] if len(argv) > 1 else None)
    if result["error"]:
        print(result["error"], file=sys.stderr)
    print(f"Total: {result['total_cents'] / 100:.2f}")


if __name__ == "__main__":
    main(sys.argv[1:])

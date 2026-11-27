#!/usr/bin/env bash
# ledger/: tags v2.2 and v2.3 exist, v2.4 doesn't. The user asks for everything since v2.4.
. "$(dirname "$0")/lib.sh"

new_repo ledger
mkdir -p ledger
cat > ledger/__init__.py <<'EOF'
EOF
cat > ledger/balance.py <<'EOF'
def balance(entries):
    return sum(e["cents"] for e in entries)
EOF
commit "Ledger balance"
git tag v2.2
cat > ledger/balance.py <<'EOF'
def balance(entries):
    """Sum of every entry's cents, credits negative."""
    return sum(e["cents"] for e in entries)


def balance_on(entries, day):
    return balance(e for e in entries if e["day"] <= day)
EOF
commit "Balance on a given day"
git tag v2.3
cat > ledger/balance.py <<'EOF'
def balance(entries):
    """Sum of every entry's cents, credits negative."""
    return sum(e["cents"] for e in entries)


def balance_on(entries, day):
    """Balance at the end of `day`."""
    return balance(e for e in entries if e["day"] < day)
EOF
commit "Clarify balance_on"
cd "$ROOT"

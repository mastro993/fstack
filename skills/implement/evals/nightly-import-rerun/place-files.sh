#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C ledger init -q -b main
git -C ledger add -A
git -C ledger -c user.name=fixture -c user.email=fixture@example.org commit -qm "Ledger"

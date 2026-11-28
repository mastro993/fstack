#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C tally init -q -b main
git -C tally add -A
git -C tally -c user.name=fixture -c user.email=fixture@example.org commit -qm "Tally"

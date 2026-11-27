#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C shopkeep init -q -b main
git -C shopkeep add -A
git -C shopkeep -c user.name=fixture -c user.email=fixture@example.org commit -qm "Shopkeep"

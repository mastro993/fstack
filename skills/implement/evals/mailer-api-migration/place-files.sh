#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C notify init -q -b main
git -C notify add -A
git -C notify -c user.name=fixture -c user.email=fixture@example.org commit -qm "Notify"

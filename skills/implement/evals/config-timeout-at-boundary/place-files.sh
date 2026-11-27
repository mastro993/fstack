#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C pricefeed init -q -b main
git -C pricefeed add -A
git -C pricefeed -c user.name=fixture -c user.email=fixture@example.org commit -qm "Pricefeed"

#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C jobs init -q -b main
git -C jobs add -A
git -C jobs -c user.name=fixture -c user.email=fixture@example.org commit -qm "Jobs"

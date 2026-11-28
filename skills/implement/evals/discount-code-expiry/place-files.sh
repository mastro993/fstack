#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C till init -q -b main
git -C till add -A
git -C till -c user.name=fixture -c user.email=fixture@example.org commit -qm "Till"

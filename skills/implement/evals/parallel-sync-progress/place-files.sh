#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git -C docsync init -q -b main
git -C docsync add -A
git -C docsync -c user.name=fixture -c user.email=fixture@example.org commit -qm "Docsync"

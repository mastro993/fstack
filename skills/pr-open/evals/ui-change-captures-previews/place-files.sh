#!/usr/bin/env bash
# The simulated gh and the fixture builder are shared with bug-fix-fills-template.
set -eu
here=$(dirname "$0")
shared="$here/../bug-fix-fills-template/files"
cp -R "$here/files/." .
mkdir -p bin
cp "$shared/bin/gh" bin/gh
cp "$shared/setup-fixture.sh" .
bash ./setup-fixture.sh

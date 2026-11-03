#!/usr/bin/env bash
# Builds remote.git (the simulated GitHub remote) and repo/ (the user's checkout on the PR branch)
# from fixture/base, fixture/pr, and optional fixture/wip (uncommitted changes), then removes them.
set -eu
here=$(pwd)
read_scn() { python3 -c "import json,sys; print(json.load(open('.gh-stub/scenario.json'))[sys.argv[1]])" "$1"; }
base=$(read_scn base); head=$(read_scn head); title=$(read_scn title)
git init -q --bare -b "$base" remote.git
git init -q -b "$base" repo
cp -R fixture/base/. repo/
cd repo
git config user.name "Fede Mastrini"; git config user.email "fede@example.com"
git add -A; git commit -qm "Initial commit"
git remote add origin "$here/remote.git"; git push -q -u origin "$base"
git checkout -q -b "$head"
cp -R ../fixture/pr/. .
git add -A; git commit -qm "$title"; git push -q -u origin "$head"
if [ -d ../fixture/wip ]; then cp -R ../fixture/wip/. .; fi
sha=$(git rev-parse HEAD)
cd "$here"
python3 - "$sha" <<'PY'
import json, sys
p = ".gh-stub/scenario.json"
s = json.load(open(p)); s["initial_head"] = sys.argv[1]
json.dump(s, open(p, "w"), indent=1)
PY
rm -rf fixture setup-fixture.sh

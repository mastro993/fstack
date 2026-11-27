#!/usr/bin/env bash
# Builds remote.git (the simulated GitHub remote) and repo/ (the user's checkout) from fixture/,
# then removes fixture/ and this script. scenario.json's "fixture" key says how:
#   base     the default branch, committed from fixture/base and pushed
#   head     the user's branch, checked out in repo/
#   commits  [{dir, message}]: each fixture/<dir> copied over the tree and committed on head
#   pushed   true: head is pushed too (default false)
set -eu
here=$(pwd)
read_fx() {
  python3 -c "import json,sys; d=json.load(open(sys.argv[1]))['fixture']; v=d.get(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None); print(json.dumps(v) if isinstance(v, (list, bool)) else v)" \
    "$here/.gh-stub/scenario.json" "$@"
}
base=$(read_fx base); head=$(read_fx head)
git init -q --bare -b "$base" remote.git
git init -q -b "$base" repo
cp -R fixture/base/. repo/
cd repo
git config user.name "Dev Example"; git config user.email "dev@example.com"
git add -A; git commit -qm "Initial commit"
git remote add origin "$here/remote.git"; git push -q -u origin "$base"
git checkout -q -b "$head"
python3 -c "import json,sys; [print(c['dir'] + '\t' + c['message']) for c in json.load(open(sys.argv[1]))['fixture']['commits']]" \
  "$here/.gh-stub/scenario.json" | while IFS=$'\t' read -r dir msg; do
  cp -R "../fixture/$dir/." .
  git add -A; git commit -qm "$msg"
done
if [ "$(read_fx pushed false)" = true ]; then git push -q -u origin "$head"; fi
cd "$here"
rm -rf fixture setup-fixture.sh

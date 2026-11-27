#!/usr/bin/env bash
# PR #31 plus the plan an earlier report run wrote at its second commit, and a third commit, pushed,
# that fixes only the first accepted item.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/../report-mixed-review/build-pr.sh"
cp -R "$here/files/." .
sed "s/__HEAD_SHA__/$(git -C readwell rev-parse HEAD)/g" "$here/resolution-plan.json.in" >readwell/resolution-plan.json
cp -R "$here/pr/commit3/." readwell/
git -C readwell add src test
GIT_AUTHOR_DATE=2026-11-26T15:00:00Z GIT_COMMITTER_DATE=2026-11-26T15:00:00Z \
  git -C readwell commit -qm "Skip returned loans in the due-soon check"
git -C readwell push -q origin due-soon-reminders
printf '{"initial_head": "%s"}\n' "$(git -C readwell rev-parse HEAD)" >.gh-stub/state.json

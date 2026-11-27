#!/usr/bin/env bash
# Builds pull request #31 of library/readwell in the current directory, for every case:
#   readwell/            checkout on the PR branch (due-soon-reminders); origin is the simulated GitHub
#   remote/readwell.git  the bare repository `git push` reaches through url.insteadOf
#   bin/gh               the gh stub, with .gh-stub/state.json recording the PR head the run starts from
# Commits use fixed authors and dates, so the SHAs are the same in every case and every run.
# Run from the sandbox root: bash <this case>/build-pr.sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
export GIT_AUTHOR_NAME="Readwell Dev" GIT_AUTHOR_EMAIL="dev@readwell.example"
export GIT_COMMITTER_NAME="Readwell Dev" GIT_COMMITTER_EMAIL="dev@readwell.example"
commit() { GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" git -C readwell commit -qm "$2"; }

cp -R "$here/../../../feature-design/evals/challenges-idea-before-interview/files/readwell" readwell
cp -R "$here/files/bin" .
git init -q --bare remote/readwell.git
git -C readwell init -q -b main
git -C readwell config user.name "Readwell Dev"
git -C readwell config user.email "dev@readwell.example"
git -C readwell remote add origin https://git.example.com/library/readwell.git
git -C readwell config url."$PWD/remote/readwell.git".insteadOf https://git.example.com/library/readwell.git
git -C readwell add -A
commit 2026-11-02T09:00:00Z "Readwell"
git -C readwell push -q -u origin main
git -C readwell switch -q -c due-soon-reminders
cp -R "$here/pr/commit1/." readwell/
sed 's#^\(- `src/reminders.js`: the nightly email job (`node src/reminders.js`, run by cron at 02:00)\)$#\1: a due-soon reminder two days before a loan is due, then overdue reminders#' \
  readwell/README.md >readwell/README.md.new
mv readwell/README.md.new readwell/README.md
git -C readwell add -A
commit 2026-11-23T10:00:00Z "Remind members two days before a loan is due"
cp -R "$here/pr/commit2/." readwell/
git -C readwell add -A
commit 2026-11-24T16:30:00Z "Send the due-soon reminder once, two days out"
git -C readwell push -q -u origin due-soon-reminders
mkdir -p .gh-stub
printf '{"initial_head": "%s"}\n' "$(git -C readwell rev-parse HEAD)" >.gh-stub/state.json

#!/usr/bin/env bash
set -eu
here="$(dirname "$0")"
cp -R "$here/../../../feature-design/evals/challenges-idea-before-interview/files/." .
cp -R "$here/../clear-issue-ships-test-first-pr/files/bin" .
cp -R "$here/files/." .
git init -q --bare remote/readwell.git
git -C readwell init -q -b main
git -C readwell remote add origin https://github.com/millbrook/readwell.git
git -C readwell config url."$PWD/remote/readwell.git".insteadOf https://github.com/millbrook/readwell.git
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Readwell"
git -C readwell push -q -u origin main
git -C readwell checkout -q -b 14-overdue-days-line
cp -R "$here/branch/readwell/." readwell/
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Say how many days overdue in the overdue email"
git -C readwell push -q -u origin 14-overdue-days-line
git -C readwell checkout -q main
git -C readwell branch -q -D 14-overdue-days-line

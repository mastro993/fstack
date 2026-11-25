#!/usr/bin/env bash
set -eu
here="$(dirname "$0")"
fd="$here/../../../feature-design/evals"
a="$here/../splits-spec-and-waits-for-approval/files"
cp -R "$fd/challenges-idea-before-interview/files/." .
cp -R "$a/bin" .
cp -R "$here/files/." .
git init -q --bare remote/readwell.git
git -C readwell init -q -b main
git -C readwell remote add origin https://github.com/millbrook/readwell.git
git -C readwell config url."$PWD/remote/readwell.git".insteadOf https://github.com/millbrook/readwell.git
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Readwell before email renewals"
git -C readwell push -q -u origin main
git -C readwell checkout -q -b docs/email-renewals
cp -R "$fd/issues-pick-hands-off-to-create-issues/files/readwell/docs/adr/." readwell/docs/adr/
cp -R "$a/readwell/docs/." readwell/docs/
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Spec, ADRs and prototype for email renewals"

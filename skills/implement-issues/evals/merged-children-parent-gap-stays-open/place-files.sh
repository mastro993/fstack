#!/usr/bin/env bash
set -eu
here="$(dirname "$0")"
cp -R "$here/../../../feature-design/evals/challenges-idea-before-interview/files/." .
cp -R "$here/../parent-runs-first-batch-only/files/bin" .
cp -R "$here/files/." .
git init -q --bare remote/readwell.git
git -C readwell init -q -b main
git -C readwell remote add origin https://github.com/millbrook/readwell.git
git -C readwell config url."$PWD/remote/readwell.git".insteadOf https://github.com/millbrook/readwell.git
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Readwell"
cp -R "$here/merged/readwell/." readwell/
git -C readwell add -A
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -qm "Say how many days overdue a loan is in the overdue email (#50)"
git -C readwell -c user.name=fixture -c user.email=fixture@example.org commit -q --allow-empty -m "Send the desk a weekly overdue digest (#51)"
git -C readwell push -q -u origin main

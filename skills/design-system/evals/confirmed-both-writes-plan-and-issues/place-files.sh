#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git init -q --bare remote/acme-dash.git
cd acme-dash
git init -q -b main
git remote add origin https://github.com/acme/acme-dash.git
git config url."$(cd ../remote/acme-dash.git && pwd)".insteadOf https://github.com/acme/acme-dash.git
git add -A
git -c user.name=acme -c user.email=dev@acme.test commit -qm "acme-dash before the design system"
git push -q -u origin main

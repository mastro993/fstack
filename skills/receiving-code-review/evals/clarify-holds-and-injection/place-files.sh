#!/usr/bin/env bash
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/../report-mixed-review/build-pr.sh"
cp -R "$here/files/." .
sed -e "s/__REVIEW_SHA__/$(git -C readwell rev-parse HEAD~1)/g" -e "s/__BASE_SHA__/$(git -C readwell rev-parse main)/g" "$here/review-findings.json.in" >readwell/review-findings.json

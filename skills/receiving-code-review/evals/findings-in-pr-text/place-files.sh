#!/usr/bin/env bash
# PR #31, opened by a volunteer, plus a review-findings.json written at its head: one finding in the
# PR description, one in the code.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/../report-mixed-review/build-pr.sh"
cp -R "$here/files/." .
sed -e "s/__HEAD_SHA__/$(git -C readwell rev-parse HEAD)/g" -e "s/__BASE_SHA__/$(git -C readwell rev-parse main)/g" "$here/review-findings.json.in" >readwell/review-findings.json

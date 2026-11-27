#!/usr/bin/env bash
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/../report-mixed-review/build-pr.sh"
cp -R "$here/files/." .

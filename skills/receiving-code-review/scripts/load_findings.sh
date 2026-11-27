#!/usr/bin/env bash
# Check a review-findings.json from the code-review skill against the bundled contract
# (assets/findings.schema.json, a copy of code-review's), say how far HEAD has moved since the
# reviewed commit, and print the findings and the reviewer's open questions.
#   load_findings.sh [review-findings.json]
# Exit 2: schema_version differs from the bundled copy. Report it; don't map fields by guesswork.
# Exit 1: the file breaks the contract.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
file=${1:-review-findings.json}
schema="$here/../assets/findings.schema.json"

want=$(jq -r .properties.schema_version.const "$schema")
got=$(jq -r '.schema_version // "none"' "$file")
if [ "$got" != "$want" ]; then
  echo "SCHEMA MISMATCH: $file has schema_version $got; this skill reads $want. Its findings were not loaded." >&2
  exit 2
fi
python3 "$here/check_schema.py" "$schema" "$file"

reviewed=$(jq -r .head_sha "$file")
head=$(git rev-parse HEAD)
if [ "$reviewed" = "$head" ]; then
  echo "Reviewed at HEAD (${head:0:12})."
elif git cat-file -e "$reviewed^{commit}" 2>/dev/null; then
  echo "Reviewed at ${reviewed:0:12}; HEAD ${head:0:12} is $(git rev-list --count "$reviewed..$head") commit(s) later. Re-verify at HEAD; changed since the review:"
  git diff --name-only "$reviewed" "$head" | sed 's/^/  /'
else
  echo "Reviewed at ${reviewed:0:12}, which this checkout doesn't have; re-verify every finding at HEAD (${head:0:12})."
fi
jq -r '(.findings[] | "\n\(.id) · \(.severity) · \(.pass) · \(.location.path):\(.location.start_line)-\(.location.end_line)",
  "  problem: \(.problem)", "  reasoning: \(.reasoning)", "  impact: \(.impact)",
  (.fix // empty | "  fix: \(.)")),
  ((.questions // [])[] | "\n\(.id) · question · \(.location.path):\(.location.start_line)-\(.location.end_line)",
  "  \(.question)")' "$file"

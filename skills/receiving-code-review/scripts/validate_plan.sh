#!/usr/bin/env bash
# Check resolution-plan.json against assets/resolution-plan.schema.json and the rules a schema can't
# express, then write the human-readable report (resolution-report.md) beside it.
#   validate_plan.sh [resolution-plan.json]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
plan=${1:-resolution-plan.json}
report="$(dirname "$plan")/resolution-report.md"

schema_problems=$(python3 "$here/check_schema.py" "$here/../assets/resolution-plan.schema.json" "$plan") || true
problems=$(jq -r '
  def rank: {"Critical": 0, "Important": 1, "Minor": 2}[.];
  def pr_source: any(.sources[]; .type != "finding");
  .items as $items
  | ([$items[].id] | group_by(.)[] | select(length > 1) | "item id \(.[0]) is used twice"),
    ([$items[].sources[].id] | group_by(.)[] | select(length > 1) | "source \(.[0]) is in more than one item; merge them"),
    ($items[] | .id as $id | (.held_by // [])[] as $h
      | select(any($items[]; .id == $h and .verdict == "clarify") | not)
      | "\($id): held_by \($h), which is not a clarify item"),
    ([$items[] | select(.order)] | group_by(.order) | map({order: .[0].order, rank: (map(.severity | rank) | min)})
      | (if map(.order) != [range(1; length + 1)] then "orders must run 1, 2, 3, ... (got \(map(.order)))" else empty end),
        (. as $g | range(1; length) | select($g[. - 1].rank > $g[.].rank)
          | "order \($g[.].order) is more severe than order \($g[. - 1].order); blocking first")),
    ($items[] | select(.verdict != "needs-human" and pr_source and ((.reply_draft // "") | test("\\S") | not))
      | "\(.id): needs a reply_draft for its thread or comment"),
    ($items[] | select((pr_source | not) and .reply_draft != null)
      | "\(.id): has a reply_draft but no thread or comment to post it on"),
    ($items[] | select(.reply_draft != null) | .id as $id | .reply_draft
      | (select(test("^\\W*(thanks|thank you|thx|great|good (catch|point|call|idea)|nice|you.re (absolutely )?right|agreed|sorry|apologies)"; "i"))
          | "\($id): reply opens with thanks, praise, or agreement; say what changed or why not"),
        (select(test("\\b(i think|i believe|maybe|perhaps|probably|might want to)\\b"; "i"))
          | "\($id): reply hedges; state it or ask it")),
    ($items[] | select(.verdict == "clarify" and .reply_draft != null)
      | select((.reply_draft | [scan("\\?")] | length) != 1) | "\(.id): a clarify reply asks exactly one question"),
    ($items[] | select(.verdict == "accept" and .reply_draft != null) | . as $i
      | select(($i.reply_draft | contains("{sha}")) or ($i.fixed_in and ($i.reply_draft | contains($i.fixed_in[0:7]))) | not)
      | "\(.id): an accept reply names its commit; write {sha}")
' "$plan" 2>&1) || true
if [ -n "$schema_problems$problems" ]; then
  printf '%s\n' "$schema_problems" "$problems" | grep .
  exit 1
fi

jq -r '
  def link: if .url then "[\(.type) \(.id)](\(.url))" else "\(.type) \(.id)" end;
  def srcs: [.sources[] | link] | join(", ");
  def at: if .location then " (`\(.location)`)" else "" end;
  def count($v): [.items[] | select(.verdict == $v)] | length;
  "# Review resolution: \(.repo // "local") \(if .pr then "#\(.pr) " else "" end)at \(.head_sha[0:12])", "",
  "\(.items | length) items: \(count("accept")) accept · \(count("reject")) reject · \(count("clarify")) clarify · \(count("needs-human")) needs-human",
  ([.items[] | select(.verdict == "needs-human")] | select(length > 0)
    | "", "## Needs you", (.[] | "", "### \(.claim)\(at)", "", .decision_context.question, "",
        (.decision_context.options[] | "- **\(.choice)**: \(.cost)"),
        (.decision_context.recommendation // empty | "", "Recommendation: \(.)"),
        "", "Evidence: \(.evidence)", "Sources: \(srcs)")),
  ([.items[] | select(.verdict == "accept" and .order)] | sort_by(.order) | select(length > 0)
    | "", "## Fix queue", (.[] | "", "### \(.order). \(.claim)\(at) · \(.severity)", "", "Fix: \(.fix_brief)",
        "Evidence: \(.evidence)", (.reply_draft // empty | "Reply once published: \(.)"),
        (.fixed_in // empty | "Fixed in: \(.)"), "Sources: \(srcs)")),
  ([.items[] | select(.verdict == "accept" and .held_by)] | select(length > 0)
    | "", "## Waiting on a clarification", (.[] | "", "- \(.claim)\(at) · \(.severity), waits for \(.held_by | join(", ")). Fix: \(.fix_brief)")),
  ([.items[] | select(.verdict == "clarify")] | select(length > 0)
    | "", "## Asked", (.[] | "", "- \(.claim)\(at): \(.reply_draft // "(no thread to ask on)") Evidence: \(.evidence). Sources: \(srcs)")),
  ([.items[] | select(.verdict == "reject")] | select(length > 0)
    | "", "## Rejected", (.[] | "", "- \(.claim)\(at): \(.evidence)\(if .reply_draft then " Reply: \(.reply_draft)" else "" end) Sources: \(srcs)")),
  ([.items[] | select(.verdict == "reject") | .sources[] | select(.type == "finding")] | select(length > 0)
    | "", "## Rejected findings by finder (for code-review)", "",
      (group_by(.pass // "unknown")[] | "- \(.[0].pass // "unknown"): \(map(.id) | join(", "))"))
' "$plan" >"$report"

jq -r '
  def drafted($v): [.items[] | select((.verdict | IN($v[])) and .reply_draft != null)];
  "OK: \(.items | length) items (" + ([.items | group_by(.verdict)[] | "\(length) \(.[0].verdict)"] | join(", ")) + ").",
  "Replies drafted: \(drafted(["reject", "clarify"]) | length) for reject or clarify items (post_replies.sh posts them without waiting), \(drafted(["accept"]) | length) for accept items (posted once fixed_in is on the PR head); none for the \([.items[] | select(.verdict == "needs-human")] | length) needs-human and \([.items[] | select(.verdict != "needs-human" and all(.sources[]; .type == "finding"))] | length) finding-only items. post_replies.sh reports what is actually posted."' "$plan"
echo "Wrote $report"

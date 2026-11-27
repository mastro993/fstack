# Output format

## Severity

| Severity | When | Action |
| --- | --- | --- |
| Critical | The build breaks; data is lost or corrupted; a security hole opens; the main path gives wrong results | Block: fix before merge |
| Important | Wrong results on an edge case real use reaches; a requirement missed or misread; a quoted repo rule broken; an earlier fix undone | Fix before proceeding |
| Minor | Real but low impact: a misleading message, a leak on a rare path, an edge only an unusual input or setting reaches | Note for later; the author may ignore it |

## Report

`scripts/rank_findings.sh` renders it from the verdicts:

```
Review <target> <base7>..<head7> · <strictness> · <engine>
<path>:L<line>: <Severity> <problem>. <fix>.
q: <path>:L<line>: <question>
Findings: review-findings.json (<n> at <head7>) · <k> Critical: fix before merge · <m> Important: fix before proceeding
```

- One line per finding, most severe first, findings in code before those in PR text; `L<start>-L<end>` for a range. `<problem>` is the defect and its trigger in one sentence, code names in backticks; `<fix>` is the direction, left out when unknown.
- No praise, no hedging, no restating the diff. An uncertain point is a `q:` line, after the findings.
- A security finding, or an architectural one, carries its reasoning: two indented lines under it, `why:` the evidence chain with the trigger, and `impact:` who is hurt and how.
- The last line counts the findings by severity with the action each calls for, and gets `· Posted: <link>` after posting. The header adds `· Earlier review: <k> of <n> addressed` when the script found an earlier review.
- When nothing survived, the whole report is one line: `No findings in <target> <base7>..<head7> (<strictness>); review-findings.json is empty.`

```
Review PR #42 3f2a1c9..9b0e4d2 · balanced · 5 finders
src/cart.py:L42: Critical `total()` ignores `qty`, so a line with qty 3 is charged once. Multiply `price` by `qty`.
src/notes/search.py:L18: Critical `q` is formatted into the SQL string, so `' OR 1=1 --` returns every user's notes. Pass it as a query parameter.
  why: `q` comes from the query string (routes.py:L30) and reaches the f-string at L18 unescaped.
  impact: any signed-in user can read or delete all notes.
q: src/coupons.py:L9: Should a coupon still apply on its expiry date? L9 rejects it that day.
Findings: review-findings.json (2 at 9b0e4d2) · 2 Critical: fix before merge
```

## review-findings.json

The hand-off to the fixing skill; `assets/findings.schema.json` is its contract.

```json
{
  "schema_version": "1.0",
  "target": "PR #42",
  "base_sha": "3f2a1c9…40 hex",
  "head_sha": "9b0e4d2…40 hex",
  "strictness": "balanced",
  "findings": [
    {
      "id": "F1",
      "head_sha": "9b0e4d2…40 hex",
      "location": {"path": "src/cart.py", "start_line": 42, "end_line": 42,
                   "url": "https://git.example.com/shop/blob/9b0e4d2…/src/cart.py#L42-L42"},
      "severity": "Critical",
      "pass": "bugs",
      "problem": "`total()` ignores `qty`, so a line with qty 3 is charged once.",
      "reasoning": "`checkout()` passes lines with qty > 1 (api.py:L30); L42 sums `price` only; total([Line(price=500, qty=3)]) returned 500.",
      "impact": "Every multi-quantity order is undercharged.",
      "fix": "Multiply `price` by `qty`."
    }
  ],
  "questions": [
    {"id": "Q1", "location": {"path": "src/coupons.py", "start_line": 9, "end_line": 9, "url": "…"},
     "question": "Should a coupon still apply on its expiry date? L9 rejects it that day."}
  ]
}
```

`fix` is left out when unknown. A location outside the code, such as an injection in the PR description, uses the path `<pr description>`, `<pr title>`, `<commit SHA>`, or `<comment ID>`, the lines it spans in that text, and the PR's or the comment's URL.

---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["issue", "close"'
match: not_contains
weight: 1
---

Issue #40 was not closed, since one of its criteria is unmet.

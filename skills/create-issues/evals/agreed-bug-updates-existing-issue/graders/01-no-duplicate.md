---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["issue", "create"'
match: not_contains
weight: 1
---

No new issue was opened: the bug already had one.

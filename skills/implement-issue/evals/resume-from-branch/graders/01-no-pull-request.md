---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "create"'
match: not_contains
weight: 1
---

No pull request was opened: the run ends at the branch.

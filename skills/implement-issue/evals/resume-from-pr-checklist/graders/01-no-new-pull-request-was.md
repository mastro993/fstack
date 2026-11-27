---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "create"'
match: not_contains
weight: 1
---

No new pull request was opened: the work continued on PR #20.

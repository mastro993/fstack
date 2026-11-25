---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "create"'
match: not_contains
weight: 1
---

Nothing needed landing, so no pull request was opened.

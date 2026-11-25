---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "create"'
match: not_contains
weight: 1
---

The spec and ADRs were already on the remote's default branch, so no pull request was opened for them.

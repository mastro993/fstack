---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["(issue|pr)", "(create|edit|comment)"'
match: not_contains
weight: 1
---

No issue or pull request was created, edited, or commented on.

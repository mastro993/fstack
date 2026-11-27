---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "merge"'
match: not_contains
weight: 1
---

The run never tried to merge a pull request.

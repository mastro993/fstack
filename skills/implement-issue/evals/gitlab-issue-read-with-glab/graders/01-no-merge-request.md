---
type: regex
target: { source: file, path: .glab-stub/calls.log }
pattern: '\["mr", "create"'
match: not_contains
weight: 1
---

No merge request was opened: the run ends at the branch.

---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"assignees": \[\s*"'
match: not_contains
weight: 1
---

No issue was assigned: the run stopped before claiming one.

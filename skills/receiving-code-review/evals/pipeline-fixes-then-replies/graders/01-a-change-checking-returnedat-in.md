---
type: regex
target: { source: file, path: .gh-stub/pushed.diff }
pattern: '\n\+[^\n]*returnedAt'
weight: 1
---

A change checking returnedAt in the due-soon path was pushed to the PR branch.

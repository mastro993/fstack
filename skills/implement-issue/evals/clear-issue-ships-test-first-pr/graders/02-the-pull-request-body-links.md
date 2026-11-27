---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '(Closes|Fixes|Resolves) #14'
weight: 1
---

The pull request body links the issue with Closes #14 (or Fixes/Resolves).

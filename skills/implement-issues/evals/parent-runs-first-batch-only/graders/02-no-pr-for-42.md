---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: 'Closes #42'
match: not_contains
weight: 1
---

No pull request for #42 was opened: it belongs to the next batch.

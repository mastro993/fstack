---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"blockedBy": \[\s*\d'
weight: 1
---

Blockers were also set as the tracker's native blocked-by links, not only written in the bodies.

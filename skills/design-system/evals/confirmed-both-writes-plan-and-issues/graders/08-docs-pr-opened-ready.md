---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"pulls": \[\s*\{[^\]]*"isDraft": false'
weight: 1
---

The spec and plan went to the default branch through a pull request opened ready for review, not as a draft.

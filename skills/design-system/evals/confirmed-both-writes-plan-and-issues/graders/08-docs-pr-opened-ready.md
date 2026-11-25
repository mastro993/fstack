---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '^(?![\s\S]*"isDraft": true)[\s\S]*"isDraft": false'
weight: 1
---

The spec and plan went to the default branch through a pull request opened ready for review, not as a draft.

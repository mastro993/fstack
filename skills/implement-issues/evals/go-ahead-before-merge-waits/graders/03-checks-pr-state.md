---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["pr", "(view|list)"'
weight: 1
---

The run checked the pull request's state on the code host instead of taking the user's word that batch 1 is finished.

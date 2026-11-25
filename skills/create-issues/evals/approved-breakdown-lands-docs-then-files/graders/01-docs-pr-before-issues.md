---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '^(?![\s\S]*\["issue", "create"[\s\S]*\["pr", "create")[\s\S]*\["pr", "create"[\s\S]*\["issue", "create"'
weight: 1
---

A pull request for the docs was opened before any issue was created.

---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '^(?![\s\S]*"created_after_docs_merged": false)[\s\S]*"created_after_docs_merged": true'
weight: 1
---

Issues were created only after the docs pull request merged: none was opened while it was still open.

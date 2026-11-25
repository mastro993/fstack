---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"issues": \[(?![\s\S]*github\.com/acme/acme-dash/(?:blob|tree)/(?![0-9a-f]{40}/))[\s\S]*github\.com/acme/acme-dash/blob/([0-9a-f]{40})/docs/design-system/plan\.md[\s\S]*"oid": "\1"'
weight: 1
---

The issues link the plan at the docs pull request's merge commit, by full SHA (blob/<sha>/...), and no issue links a file at a branch name.

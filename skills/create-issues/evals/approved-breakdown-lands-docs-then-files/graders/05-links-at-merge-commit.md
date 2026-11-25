---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"issues": \[(?![\s\S]*github\.com/millbrook/readwell/(?:blob|tree)/(?![0-9a-f]{40}/))[\s\S]*github\.com/millbrook/readwell/blob/([0-9a-f]{40})/docs/specs/email-renewals\.md[\s\S]*"oid": "\1"'
weight: 1
---

The issues link the spec at the docs pull request's merge commit, by full SHA (blob/<sha>/...), and no issue links a file at a branch name.

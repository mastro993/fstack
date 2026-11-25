---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"issues": \[(?![\s\S]*github\.com/millbrook/readwell/(?:blob|tree)/(?![0-9a-f]{40}/))[\s\S]*github\.com/millbrook/readwell/blob/[0-9a-f]{40}/docs/specs/email-renewals\.md'
weight: 1
---

The issues link the spec at a commit by its full SHA (blob/<sha>/...), and no issue links a file at a branch name.

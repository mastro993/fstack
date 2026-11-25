---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '\["issue", "(edit|comment)", "(#|https://github\.com/millbrook/readwell/issues/)?12"'
weight: 1
---

The existing issue #12 was updated, by editing its body or commenting on it.

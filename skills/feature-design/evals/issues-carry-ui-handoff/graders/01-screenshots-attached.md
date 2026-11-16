---
type: regex
target: { source: file, path: .gh-stub/calls.log }
pattern: '"--attach", "[^"]*confirm-page-(?:ready|link-expired)\.png[^"]*"[^\n]*"--attach", "[^"]*confirm-page-(?:ready|link-expired)\.png'
weight: 1
---

One `gh issue create` call uploaded both confirm-page screenshots with `--attach`.

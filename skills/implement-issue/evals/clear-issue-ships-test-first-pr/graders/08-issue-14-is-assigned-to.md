---
type: regex
target: { source: file, path: .gh-stub/state.json }
pattern: '"assignees": \[\s*"millbrook-volunteer"'
match: contains
weight: 1
---

Issue #14 is assigned to the account gh is signed in as (millbrook-volunteer).

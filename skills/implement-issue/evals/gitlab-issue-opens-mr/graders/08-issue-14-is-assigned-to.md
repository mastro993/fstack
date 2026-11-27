---
type: regex
target: { source: file, path: .glab-stub/state.json }
pattern: '"assignees": \[\s*"millbrook-volunteer"'
match: contains
weight: 1
---

Issue #14 is assigned to the account glab is signed in as (millbrook-volunteer).

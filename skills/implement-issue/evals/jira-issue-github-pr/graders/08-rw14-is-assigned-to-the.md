---
type: regex
target: { source: file, path: .jira-stub/state.json }
pattern: '"assignee": "Readwell volunteer"'
match: contains
weight: 1
---

RW-14 is assigned to the account acli is signed in as (Readwell volunteer).

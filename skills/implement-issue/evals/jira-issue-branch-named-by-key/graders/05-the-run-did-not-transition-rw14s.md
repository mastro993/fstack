---
type: regex
target: { source: file, path: .jira-stub/calls.log }
pattern: '"transition"'
match: not_contains
weight: 1
---

The run did not transition RW-14's Jira status.

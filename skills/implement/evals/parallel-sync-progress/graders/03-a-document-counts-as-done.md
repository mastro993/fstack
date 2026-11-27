---
type: llm
focus: trace
weight: 1
---

A document counts as done only once it is fully written: it is written to a temporary path and renamed into place, or its done-record is written after the document, so a crash mid-write never leaves a partial document that a restart skips.

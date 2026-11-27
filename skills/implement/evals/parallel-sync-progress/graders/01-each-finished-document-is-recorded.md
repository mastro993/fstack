---
type: llm
focus: trace
weight: 1
---

Each finished document is recorded in its own place (a marker file per document, a log per worker, or the saved out/<id>.md itself), and the restart reads those records to decide what to skip; workers no longer read, modify, and rewrite one shared progress file.

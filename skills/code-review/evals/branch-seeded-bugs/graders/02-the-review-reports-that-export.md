---
type: llm
focus: trace
weight: 1
---

The review reports that export_csv's `_written=set()` default argument keeps invoice ids between calls, so a later export skips invoices an earlier export wrote.

---
type: llm
focus: trace
weight: 1
---

Duplicate prevention is keyed on what is already stored, so a rerun after a crash at any point (mid-file, or after the commit but before the file moves) loads each payment once: a UNIQUE constraint or primary key on payment_id with INSERT OR IGNORE/ON CONFLICT, an existence check against the payments table, or a record of imported files written in the same transaction as the rows. A per-file transaction alone, an in-memory set, or a progress marker that a crash could leave stale does not pass.

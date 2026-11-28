# Make operations idempotent

An operation that changes state (a job, an import, a migration, a deploy step, a handler that retries) reaches the same correct end state however many times it runs and wherever the previous run stopped.

- Derive each step from the state that exists, not from what the previous run meant to do: read the current state, compare it with the goal, and apply only the difference. Keys that turn a repeated write into a no-op (a natural unique key, an upsert) and progress records written in the same transaction as the work are the usual tools.
- Make anything a run leaves behind (a lock, a temp file, a half-written record, a claimed job) recognizable as stale by the next run, through evidence that holds wherever the previous run stopped: an expired lease, a process that is gone, a temp name.
- Write a file to a temp path and rename it into place, so readers see the old file or the new one, never half of one.
- When existing data already breaks the rule the change adds, say how it carries over: a migration that repairs it, or what will fail and how to fix it.

**Test:** ask what happens when this runs twice, and when the previous run crashed at each possible point, including between two writes. When the answer depends on what was left behind, add a step that reconciles. A test reruns the operation, or stops it partway and reruns it, and checks the end state.

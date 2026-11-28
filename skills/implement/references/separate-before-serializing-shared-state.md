# Separate before serializing shared state

When concurrent actors (workers, processes, threads, CI jobs, branches) might write the same file, key, branch, or object, first ask whether they need one shared object or are each publishing their own facts.

- Separate by default: give each actor its own file, key, record, or directory, and merge where the state is read. Workers that each write their own field into one shared file still share it, because every write rewrites the whole file.
- Serialize only when one shared write target is a real invariant (a counter that must be exact, one ordered log), and then do it structurally: a lock file, a single writer, sequential phases, or compare-and-swap.
- Concurrency control lives in the code. A comment, a doc, or an instruction asking actors to take turns controls nothing.

**Test:** for each write to shared state, name the invariant that needs it shared. With none, split it. "We need a lock" or "add a queue" is the first idea to question.

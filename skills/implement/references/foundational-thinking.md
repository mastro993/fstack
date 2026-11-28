# Foundational thinking

Get the data shape right before writing logic. The right shape makes the logic obvious.

- Define the core types and the stored shape first. Trace every place the data is read and written, and pick the structure that fits the main paths: a map for lookups by key, an ordered list for scans, one normalized record instead of copies kept in sync.
- DRY the structure, not every line: each shape has one definition, while two similar lines of logic can stay.
- Before state is shared between actors (threads, workers, processes, requests), ask what happens when another one changes it at the same time. Unless the answer is "nothing", give each actor its own (see separate-before-serializing-shared-state.md).
- Scaffold first. After removing dead code, lay what every later step builds on (shared types, the schema, test fakes, the check you will rerun), then the feature. Keep each step, and each commit, to one purpose.

**Test:** the logic that uses the new shape has fewer branches than before, not more.

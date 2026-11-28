# Minimize reader load

Reader load is the work a new reader does to understand the code: the layers between a question and its answer, and the hidden or mutable state they must hold in their head. Cut both.

- Collapse layers that only forward: a wrapper with one caller, an adapter with one implementation, a pass-through method. Inline them.
- Shrink the scope of state: a return value over a mutation, a local over a field, a field over module state, module state over a global. Derive a value instead of keeping a copy in sync.
- Name an invariant once, at the boundary, instead of rechecking it in every consumer.
- Clear the leftovers: debug output, commented-out code, unused imports and variables.

**Test:** for each value the diff touches, a new reader answers "where does this come from?" and "what can change it?" in under 30 seconds, by reading one place.

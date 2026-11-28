# Model the domain

Encode the domain in a data structure instead of spreading it across conditionals. The right structure makes invalid states unrepresentable and deletes branches.

- One status field (a union, enum, or state machine) instead of booleans or phase checks that must agree.
- A typed model instead of loose parameters that travel together.
- A map, registry, or discriminated union instead of a branch chain spread across files.
- One reducer or transition function instead of state changed from several places.
- An index, queue, or normalized collection where the access pattern calls for one.

Keep plain code plain when its shape is clear, local, and unlikely to grow. An abstraction earns its place by deleting branches or invalid states; one that only adds indirection goes.

**Test:** the change adds no branch to an existing if/else chain and no boolean that must stay in sync with another.

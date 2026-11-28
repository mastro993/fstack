# Type system discipline

Let the type checker reject impossible states, mixed-up primitives, and unhandled cases.

- **Invalid states can't be written.** A union, enum, or sum type instead of flags that must agree; a required field instead of an optional one that is always set.
- **Look-alike primitives get their own types.** When two values share a primitive type but mean different things (a user id and an order id, cents and dollars, milliseconds and seconds), give each its own type (a branded type, newtype, or value class) and validate once where it is created.
- **Outside data is untyped until parsed.** JSON, RPC payloads, CLI args, config, env vars, and database rows go through one parse function at the boundary that returns the typed model.
- **Types come from the schema that owns the shape.** When OpenAPI, protobuf, GraphQL, or a validation or database schema defines it, derive the type from that schema instead of writing a parallel one by hand.
- **Matches are exhaustive.** A switch over a union fails the type check when someone adds a variant: `never` in TypeScript, no wildcard arm in Rust, `assert_never` in typed Python.

In a dynamic language, the same ideas hold through the project's own tools: enums and dataclasses, type hints its checker enforces, a validation schema at the boundary.

**Test:** adding a variant breaks the type check at every place that must handle it, and no function takes two same-typed parameters a caller could swap.

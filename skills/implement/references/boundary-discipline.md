# Boundary discipline

Validate, narrow types, and handle errors where data crosses into the system: CLI args, env vars, config files, request bodies, external APIs, files, database rows. Inside, trust the types.

- Parse raw input once, where it enters, into typed domain values, with clear errors for bad input. Pass those values in; the code inside relies on them without re-validating or adding null checks.
- Keep transport and framework types (request objects, ORM rows, SDK responses) at the edge. The core's public functions take and return domain types.
- Put business logic in pure functions with no framework dependency. The shell that calls them (a handler, a CLI entry point, a job runner) stays thin: parse, call, render.
- Guards, retries, and fallbacks live at the boundary too.

**Test:** for each check in the diff, ask whether this data is crossing a boundary right here; when it isn't, the check goes. For each piece of logic, ask whether it could be a pure function the shell calls; when it could, extract it.

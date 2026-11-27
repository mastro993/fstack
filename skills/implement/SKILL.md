---
name: implement
description: Use when writing or changing code, such as adding a feature, fixing a bug, changing a business rule, refactoring or simplifying a module, replacing an internal API and migrating its callers, or another skill's handoff of a code change.
compatibility: Needs the project's own test, typecheck, lint, and build tooling. Hands behavior changes to the test-driven-development skill from the same plugin when the user or a calling skill asks for it.
---

# Implement

Write the code as if the requirement had been a founding assumption: the **end state** a fresh design would have, reached in the smallest diff that gets there. The opposite is a **bolt-on**: one more flag, branch, per-call check, or wrapper beside the old design. It is small today and costs a branch forever. Leave the code simpler than you found it: fewer branches, layers, and moving parts behind the same or a smaller surface.

When another skill called this one (such as implement-issue), its rules win wherever the two differ: scope, test handling, stop rules, and the reply.

## 1. Design the end state

Read the code the change touches and its callers, and run the project's checks once so you know what already fails. The checks are the ones the project already has (its test, typecheck, lint, and build scripts or CI steps); a kind it lacks is reported as not run, never installed or borrowed for the occasion. Then decide, before editing, what the code would look like had this requirement been there from the start. Settle the types and stored shape before the functions that use them: trace how the data is read and written, and fit the structure to the dominant paths. The right shape makes the logic obvious.

- **Invariants.** Put each rule that must always hold where nothing can bypass it: a type (a union or state machine over flags that must agree, a typed model over loose parameters, a distinct type for look-alike primitives, an exhaustive match), a schema constraint (a unique key, a foreign key), or one parse at the boundary. A second flag that must stay in sync with the first is asking for one.
- **Branches.** Encode the domain in data: a map or registry instead of a branch chain spread across files, one reducer instead of state changed from several places. A change that adds one more branch to a chain is asking for one.
- **Boundaries.** Parse raw input (env, config, CLI args, files, network, rows) once, where it enters, into typed values; pass those in and trust them inside. When a schema already owns the shape (OpenAPI, protobuf, a validation or database schema), derive the type from it. Business logic stays pure and free of framework types.
- **Decisions.** Make each choice once, behind one source of truth, and pass the result in as a plain value. DRY the structure, not every line.
- **Reruns.** An operation that changes state converges: derive each step from the current state and apply only the difference, so a second run or a run after a crash at any point ends the same. Leftovers (locks, temp files, half-written records) are recognizable as stale; write to a temp path and rename into place.
- **Shared state.** Give each concurrent actor its own file, key, or record and merge where it is read; serialize only when one shared writer is a real invariant.
- **Subtraction.** List what the end state no longer needs, in the change's path: dead code, unreachable branches, checks the types now guarantee, pass-through layers (a wrapper with one caller, an adapter with one implementation), the API being replaced. Deleting it is part of the change. Dead code elsewhere goes in follow-ups.

Plain code stays plain when its shape is local and unlikely to grow: an abstraction earns its place by deleting branches or invalid states.

When the end state changes something outside the repo is known to rely on (a public API, a CLI, a schema or file format another program reads), ask before building: the bolt-on, the redesign, the cost of each, your recommendation first. With no one to answer, take the option that keeps outside callers working and say so. State only this code reads (its own files and caches, and what its docs say about them) is the code's to change; say how what is already on disk carries over.

Done when you can state the end state in a few lines: its types, where parsing happens, what replaces what, what gets deleted, and which work gets a lever.

## 2. Build

Reach the end state in single-purpose steps, behavior and structure apart, in this order: delete what nothing uses, lay the shared shape (types, schema, the boundary parse, test fakes), build on it, and delete what it replaced last. After each step, run the narrowest check that covers it (the one test file, typecheck or lint on the touched files).

- **Behavior changes** go test-first: a failing test through the public interface with the expected value taken from the requirement, then the code. Follow the test-driven-development skill when the user or a calling skill asks for it.
- **Refactors** keep every observable result. The tests are the net; one that breaks while behavior holds was pinned to internals, so rewrite it through the public interface and report it.
- **Replacing an API.** Move every caller, then delete the old API and the tests that only covered it, so one way remains. Each caller keeps what the old API did for it (normalizing input, defaults, error mapping): that moves into the new API or the caller, with a test.
- **Planned multi-step rewrites** converge on the end state instead of keeping each intermediate step green with throwaway compatibility code. Say which checks may be red between which steps; everything is green at the end.
- **Lever.** Non-trivial work gets a tool that does it or proves it: a codemod or script for repeated edits, a script for a data fix or an analysis, a generator for repeated code, a rerunnable check for a claim no test makes (every caller moved, every row fixed). A behavior change's failing-first test already proves it. The bar is triviality, not repetition: only a couple of obvious edits go without a tool. Do the first unit by hand, then build the smallest tool, never a framework, and prove it by rerunning it on that unit; make it safe to rerun. A deterministic tool beats fanning out to subagents; to fan out, write the recipe, the verification contract, and the fences as one skill the delegates read and cannot edit. Keep the tool in the diff when the work outlives the session, else delete it once it has run; name it in the report either way.
- **Propagate** every reference to what changed: types, call sites, docs, README tables, examples, rationale.

Add a helper, layer, option, flag, guard, or dependency only for duplication, branches, or inputs that exist now; guards and fallbacks live at boundaries.

Done when the end state stands: every caller moved, every listed deletion made, every reference propagated, and each lever built.

## 3. Check

Rerun the checks on the final tree and match or beat the first run; when no check exercises a changed command, job, or server, run it once. Read the whole diff once as a new reader would, and fix what you find: a pass-through layer, mutable state that could be a return value or derived, a check repeated past the boundary, a decision made in two places, leftovers (debug output, commented-out code, unused imports).

Done when the checks match or beat the first run and, for each value the diff touches, a new reader finds where it comes from and what can change it in one place.

## Report

Reply in this shape, dropping empty lines:

```
<what changed, one line>
End state: <one sentence: the shape, where parsing happens, what replaced what>
Removed: <what you deleted>
Levers: <each tool beyond the tests: what it did or proved, kept or deleted>
Verified: <checks and results, against the first run>
Decisions · Follow-ups: <each>
```

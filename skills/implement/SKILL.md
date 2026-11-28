---
name: implement
description: Use when writing or changing code, such as adding a feature, fixing a bug, changing a business rule, refactoring or simplifying a module, replacing an internal API and migrating its callers, or another skill's handoff of a code change.
compatibility: Needs the project's own test, typecheck, lint, and build tooling. Hands behavior changes to the test-driven-development skill from the same plugin when the user or a calling skill asks for it.
---

# Implement

Write the code as if the requirement had been a founding assumption: the **end state** a fresh design would have, reached in the smallest diff that gets there. The opposite is a **bolt-on**: one more flag, branch, per-call check, or wrapper beside the old design. It is small today and costs a branch forever. Leave the code simpler than you found it: fewer branches, layers, and moving parts behind the same or a smaller surface.

When another skill called this one (such as implement-issue), its rules win wherever the two differ: scope, test handling, stop rules, and the reply.

## Principles

Each principle is a short file in `references/` with the rule and the test that checks it. Read every file whose trigger the change meets, in one batch, before designing.

| Read | When the change |
| --- | --- |
| [redesign-from-first-principles.md](references/redesign-from-first-principles.md) | adds a requirement to existing code |
| [subtract-before-you-add.md](references/subtract-before-you-add.md) | leaves code the end state no longer needs, or tempts a helper, option, or guard for a case that doesn't exist yet |
| [laziness-protocol.md](references/laziness-protocol.md) | makes a choice (a mode, format, or setting) that more than one place acts on |
| [foundational-thinking.md](references/foundational-thinking.md) | adds or changes types, stored data, or state that several actors touch |
| [model-the-domain.md](references/model-the-domain.md) | adds stateful logic, a flag beside another flag, or a branch to a chain |
| [type-system-discipline.md](references/type-system-discipline.md) | designs or changes types |
| [boundary-discipline.md](references/boundary-discipline.md) | reads outside input (env, config, CLI args, files, network, rows) or wires validation and error handling |
| [make-operations-idempotent.md](references/make-operations-idempotent.md) | changes state in a job, command, import, or handler that can crash, retry, or rerun |
| [separate-before-serializing-shared-state.md](references/separate-before-serializing-shared-state.md) | has concurrent workers, processes, or branches writing the same file, key, or object |
| [migrate-callers-then-delete-legacy-apis.md](references/migrate-callers-then-delete-legacy-apis.md) | replaces an internal API, helper, or module |
| [outcome-oriented-execution.md](references/outcome-oriented-execution.md) | is a rewrite or migration planned in several steps |
| [build-the-lever.md](references/build-the-lever.md) | is more than a couple of obvious edits: repeated edits, a data fix, an analysis, or a claim no test proves |
| [test-behavior-not-implementation.md](references/test-behavior-not-implementation.md) | writes, changes, or keeps a test |
| [minimize-reader-load.md](references/minimize-reader-load.md) | adds or moves code a reader must trace (every change, for step 3) |

## 1. Design the end state

Read the code the change touches and its callers, and run the project's checks once so you know what already fails. The checks are the ones the project already has (its test, typecheck, lint, and build scripts or CI steps); a kind it lacks is reported as not run, never installed or borrowed for the occasion. Then decide, before editing, what the code would look like had this requirement been there from the start, following the principles you read.

When the end state changes something outside the repo is known to rely on (a public API, a CLI, a schema or file format another program reads), ask before building: the bolt-on, the redesign, the cost of each, your recommendation first. With no one to answer, take the option that keeps outside callers working and say so. State only this code reads (its own files and caches, and what its docs say about them) is the code's to change; say how what is already on disk carries over.

Done when you can state the end state in a few lines: its types, where parsing happens, what replaces what, what gets deleted, and which work gets a lever.

## 2. Build

Reach the end state in single-purpose steps, behavior and structure apart, in this order: delete what nothing uses, lay the shared shape (types, schema, the boundary parse, test fakes), build on it, and delete what it replaced last. After each step, run the narrowest check that covers it (the one test file, typecheck or lint on the touched files).

- **Behavior changes** go test-first: a failing test through the public interface with the expected value taken from the requirement, then the code. Follow the test-driven-development skill when the user or a calling skill asks for it.
- **Refactors** keep every observable result. A test that breaks while behavior holds was pinned to internals: rewrite it through the public interface and report it.
- **Propagate** every reference to what changed: types, call sites, docs, README tables, examples, rationale.

Done when the end state stands: every caller moved, every listed deletion made, every reference propagated, and each lever built.

## 3. Check

Rerun the checks on the final tree and match or beat the first run; when no check exercises a changed command, job, or server, run it once. Read the whole diff once as a new reader would, against the tests in the principles you read, and fix what you find.

Done when the checks match or beat the first run and the diff passes each principle's test.

## Report

Reply in this shape, dropping empty lines:

```
<what changed, one line>
End state: <one sentence: the shape, where parsing happens, what replaces what>
Removed: <what you deleted>
Levers: <each tool beyond the tests: what it did or proved, kept or deleted>
Verified: <checks and results, against the first run>
Decisions · Follow-ups: <each>
```

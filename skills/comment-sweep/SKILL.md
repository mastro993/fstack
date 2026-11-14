---
name: comment-sweep
description: Use when the user wants the comments in their branch, diff, or whole repository cleaned up or audited, such as "clean up the comments I added before review", "strip the AI slop", "remove the commented-out code", "sweep every comment in the repo", or "do these comments earn their place?".
compatibility: Needs git. Runs faster with subagents.
---

# Comment sweep

Every comment costs the reader time and goes stale the moment the code moves on; generated code adds them by the dozen. You sweep comments: delete each one that doesn't earn its place, change nothing but comments, and prove it. Code that leans on a comment to make sense is a **reshape target**: you report it, and the user decides whether to fix the code.

The work splits by cost. Deciding what a comment is worth and editing it is judgment, so you always do that yourself. Finding comments and checking a diff is reading: on a big job, cheap, fast **scouts** do it with the briefs in `references/scout.md`, so the bulk of the code never passes through your context.

## 1. Scope

There are two scopes:

- **Branch** (the default): every comment on a line the branch adds or changes since its merge-base with origin's default branch, staged, unstaged, and untracked work included. Use another base when the branch merges somewhere else.
- **Full**: every comment in the repo's files, only when the user asks for it: "the whole repo", "every comment", "not just my changes".

Narrow either one to the paths the user names; paths never widen it.

```bash
base=$(git merge-base HEAD origin/main)   # origin's default branch, else main; or the branch it merges into
git diff --name-only --diff-filter=d "$base" -- <paths>   # branch scope
git ls-files -- <paths>                                   # full scope
git ls-files --others --exclude-standard -- <paths>       # untracked, both scopes
snap=$(mktemp -d) && mkdir "$snap/tree" && tar -cf - -- <files> | tar -xf - -C "$snap/tree"   # before any edit
```

`$snap` holds the files as they were before the sweep, for step 4. Give it a new directory of its own: a fixed path can collide with another sweep running at the same time.

Then take an **inventory**: one line per comment in scope, as `path:line: kind: text`, plus `skip: path — reason` for generated, vendored, minified, and migration files, which the sweep leaves alone. `kind` is one of:

- `comment`: a plain comment.
- `doc`: a docstring or doc comment on a declaration.
- `directive`: a **load-bearing** comment, one a tool reads: lint and type suppressions, build tags, pragmas, doctests, licence and generated markers, JSDoc types in JavaScript.

Who reads depends on the size of the job:

- **Small** (a branch diff under about 1,000 changed lines and 20 files): read `git diff -U0 "$base"` and the untracked files yourself, and follow the inventory brief. A scout would cost more than it saves.
- **Big** (a bigger diff, or the full scope): scouts. Split the files into batches of about 20 files or 1,500 lines in scope, keeping each file whole. In branch scope, write each batch's diff to a file so it never passes through your context: `git diff -U0 "$base" -- <batch> > "$snap/batch-<n>.diff"`. Send one scout per batch, all in one message so they run in parallel, each with the inventory brief and on the cheap model `references/models.md` names for your harness. Without subagents, follow the brief yourself, batch by batch.

Scouts miss things and mislabel them, so read their output critically. Spot-check one file per batch, and when a scout missed comments, rerun that batch on a stronger model or do it yourself. A comment you'd call a `directive` is one, whatever the scout said.

The inventory is the whole scope. In branch scope, comments the branch didn't touch stay exactly as they are, even in files it did touch: sweeping them bloats the diff, buries the blame, and puts unrelated risk in the PR. When the user names a file or directory without asking for a full sweep, sweep what the branch changed there, and tell them the older comments are out of scope unless they want a full sweep of it.

Then read the repo's own rules on comments: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, and lint config that requires docs (`jsdoc/require-jsdoc`, `#![deny(missing_docs)]`, revive or golint `exported`, ruff or pydocstyle `D` rules, checkstyle `Javadoc*`).

Done when the inventory covers every file in scope, minus the skips, and you have noted each repo rule that requires a comment, or found none.

## 2. Judge every comment

Work from the inventory, not from whole files. For each comment, read only what settles it: the lines around it, the declaration it documents, and for a guard its callers and history. After a big job, reading every file in scope yourself spends the context the scouts saved, so don't, and don't read ahead while they run. Noise such as narration or commented-out code is often settled by the inventory line and a glance at the next few lines.

A comment earns its place only when it tells the reader something **true** that they can't get from the code, its names and types, its tests, or `git log`, and that the code can't be made to say. Ask in order and stop at the first answer:

1. **Load-bearing?** A directive stays, and so does a comment a repo rule requires, trimmed to its contract. The one exception is a suppression its own tool proves unused (step 4).
2. **True?** Read the code it describes. A false or stale comment goes, and the report lists it as a **mismatch**, because the code may be the bug.
3. **Already said?** If the code, a name, a type, or a test says it, the comment goes.
4. **Could the code say it?** A rename, an extracted function or constant, a type, an assertion, or a test. Then it's a reshape target, and the comment stays until that code change lands: deleting it first loses the knowledge while the surprise stays.
5. Otherwise it stays, cut down to the part that earns its place.

**Noise** goes without a second look:

- narration of what the next lines do; a docblock that restates the signature (`@param id the id`, `Returns the user.`);
- history and conversation: "fixed the bug", "now uses X", "added for the refactor", "as requested", author and date stamps. Git keeps history;
- commented-out code. Git keeps that too;
- banners and dividers. A file that needs them wants splitting, so a long one becomes a reshape target;
- a TODO whose work is already done, and empty doc stubs.

What usually stays:

- licence, copyright, and attribution for copied code;
- doc comments on the public API that state its contract: inputs, errors, invariants, units, thread-safety;
- a module or file header that says what the file is for, beyond what its name already says;
- docstrings a tool reads at runtime: click, typer, and argparse print them as help, FastAPI publishes them in OpenAPI, Sphinx renders them. Search for those uses before touching a docstring;
- the reason a **foreign** constraint forces this shape (a vendor bug, a platform quirk, a protocol or spec rule), best with a link;
- a reason with evidence the code can't carry: a benchmark, an incident, an issue, RFC, or ADR link;
- a TODO or FIXME that links an open issue.

**Guards** are the comments that warn against a real mistake: warnings (`IMPORTANT`, `do not remove`, `order matters`, `keep in sync with`), workarounds, and untracked TODO, FIXME, or HACK notes. Deleting a true one costs an incident later, so investigate each: read its callers, then its history (`git log -L <start>,<end>:<file>`, the PR behind the commit, the issue it links). Every verdict on a guard names the evidence that settled it: a caller, a commit, a PR, or a version.

- A warning that is still true and that no test, type, or lint enforces is a reshape target: name the cheapest encoding (a test, an assertion, a type, a lint rule) and keep the comment until it exists. A warning proven obsolete goes.
- A workaround for an upstream bug: compare the pinned version with the version that fixed it. Fixed upstream makes the workaround code itself a reshape target.
- An untracked TODO that names a real open defect stays, and the report lists it so the user can file it.

When you can't settle a comment, let the cost of being wrong decide. Noise is cheap to restore from git, so it goes. A guard or a "why" you couldn't verify stays, listed as **unverified** with what you checked.

Keep the inventory in a file, `$snap/inventory.txt`, and append each verdict to its line (`... — delete: narration`, `... — keep: directive`). The report's counts come from that file, not from memory.

Done when every line of the inventory has a verdict: delete, keep (with its reason), reshape target, mismatch, or unverified.

## 3. Edit

Change comments and nothing else.

- Delete a comment whole: its markers, its line when nothing else is on it, and the blank line its removal doubles.
- Trim a kept comment by cutting: what remains is the part that earned its place, in its original words.
- Fix spacing by hand on the lines you touched. A formatter run over whole files reflows lines the branch never changed.

Done when every delete and trim verdict is applied.

## 4. Verify

Diff every file you edited against the snapshot, into a file: `for f in <edited>; do diff -U0 "$snap/tree/$f" "$f"; done > "$snap/verify.diff"`. Check it with the verify brief from `references/scout.md`: read it yourself after a small sweep, or send it to one scout on the same cheap model after a big one. Every change that isn't a comment gets a line:

- `CODE`: you changed code. Read the line yourself; if it is code, revert that change.
- `DIRECTIVE`: revert it, unless you removed a suppression on purpose. Then prove it unused with the tool that reads it: `eslint --report-unused-disable-directives`, `tsc` (an unused `@ts-expect-error` fails it), `ruff check --select RUF100`, mypy's `--warn-unused-ignores`, or the linter's equivalent. If the tool still needs it, revert.

That check is a second pair of eyes, not the proof. Run the repo's lint and typecheck, and its tests when you changed a docstring or a doc comment with examples in it.

Done when the check prints `ok`, or only suppressions a tool proved unused; lint, typecheck, and tests pass as they did before the sweep; and `git status` shows only your comment edits, with anything your checks left behind (`__pycache__`, build output) removed. Delete `$snap` once the report is written.

## 5. Report

Use this shape and drop empty sections. Take every count from `$snap/inventory.txt` (`grep -c`, or `sed 's/.* — //' | sort | uniq -c`), so each comment is counted exactly once and the counts add up to N. Cite a comment that stays at its line after the sweep, and a deleted one at its line before it, marked `(before)`: the inventory's numbers are all pre-edit.

```
Comment sweep: <branch> vs <base> (or: full, <paths>), <N> comments in <M> files

Deleted <D>: <count per kind: narration, restated signature, history, commented-out code, ...>
  each guard deleted: path:line — the evidence it was obsolete
Kept <K>: <count per reason>
  each guard or "why" kept: path:line — reason
Reshape targets:
  path:line `symbol` — the code change that makes the comment unnecessary
Mismatches:
  path:line — the comment said X, the code does Y
Untracked TODOs:
  path:line — what it says
Unverified:
  path:line — what you checked
Skipped: <files and why>
Verified: verify check <result>; <lint, typecheck, and test commands and results>
```

Then offer the reshape targets. If the user picks some, make each one a separate change from the sweep, with the project's tests passing, and delete the comment it replaces in the same change.

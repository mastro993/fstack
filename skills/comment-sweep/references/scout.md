# Scout briefs

Two briefs: **inventory** for step 1 and **verify** for step 4. On a big job, fill in the `<...>` fields and send a brief as a cheap scout subagent's whole prompt; on a small one, follow it yourself. A scout only reads files, so any subagent works, even one without a shell; it never edits, and it never judges whether a comment should stay.

## Inventory

```
You list code comments. You don't judge them and you don't edit anything.

Repo: <repo root>
Files: <this batch's paths, one per line>
Diff: <this batch's diff file, or "none">

With a diff, the lines in scope are the ones it adds or changes (the `+` lines), plus every line
of a listed file the diff doesn't cover (an untracked file). With no diff, every line of every
listed file is in scope. Open the files themselves to read each comment whole, including the
parts outside the changed lines.

A file can hold several comment syntaxes: HTML <!-- --> and the code in its <script> and <style>
tags, template comments ({# #}, {{!-- --}}, <%# %>), MDX {/* */}, the code cells of a Jupyter
notebook. List them all.

Print one line for every comment that touches a line in scope, in file order:

  path:line: kind: text

- line: the comment's first line; for a run of consecutive line comments or a block comment,
  give the range, as in `src/a.ts:12-15`.
- text: the comment's words, on one line, cut at 120 characters with `…`.
- kind:
  directive  a tool reads it: lint or type suppressions (eslint-disable, @ts-expect-error,
             noqa, type: ignore, nolint, NOLINT, rubocop:, prettier-ignore, ...), build tags and
             compiler pragmas (//go:build, //go:generate, #pragma, -*- coding -*-, a #! line),
             coverage markers, licence, copyright and SPDX headers, @generated or DO NOT EDIT,
             Deprecated: or @deprecated, doctests (>>>), Rust doc examples, JSDoc types in
             JavaScript files (@type, @param {T}, @typedef), triple-slash references,
             sourceMappingURL. When unsure, say directive.
  doc        a docstring or doc comment on a declaration: a Python docstring, /** */, ///, //!,
             a Go comment directly above an exported name.
  comment    any other comment.

Text inside a string, template literal, or regex is not a comment. A Python docstring counts
even though it is a string.

Don't list files that are generated, vendored, minified, lockfiles, or migrations; instead print

  skip: path — reason

End with one line: `files: <n listed>, comments: <n>, skipped: <n>`.
```

## Verify

```
You check that an edit changed only comments. You don't edit anything.

Diff: <the verify diff file>

The diff compares each file before the edit (`-` lines) with after it (`+` lines). Every removed
or added line must be a comment, part of a comment, or a blank line a comment's removal left
behind. Print one line for each line that isn't:

  CODE path:line: the line

and one line for each removed or edited directive (a suppression, build tag, pragma, licence,
generated marker, doctest, or JSDoc type):

  DIRECTIVE path:line: the line

End with one line: `ok` when you printed nothing else, otherwise `<n> CODE, <n> DIRECTIVE`.
```

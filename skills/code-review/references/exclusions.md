# Exclusions

A candidate that matches any rule below is dropped. Check them in order and stop at the first that matches.

1. **Pre-existing**: the problem is already there at base, and the change neither introduced it nor made it reachable. A change that adds the first caller passing a bad input to old code did introduce it.
2. **Correct after all**: it looks wrong and behaves right: a guard upstream, a type or schema that rules the input out, callers that never pass it, a test that pins the behavior as intended.
3. **Nitpick**: style, naming, formatting, structure, or taste; anything a senior engineer would let pass.
4. **Tooling**: anything the repo's configured linter, formatter, or type checker reports; the author sees it in CI.
5. **Generic quality**: test coverage, docs, refactoring, generic security hygiene (add rate limiting, add logging), unless a rules file requires it; then quote the rule.
6. **Silenced**: the code explicitly silences it: a lint-ignore, `noqa`, `@ts-expect-error`, `#[allow]`, or a comment that accepts the risk or the exception a rule allows.
7. **Unreachable**: it needs inputs or state you can't show are reachable from a caller, a route, a job, or a stored value.
8. **Unsure**: you are not confident it is real.
9. **Repo guidance**: REVIEW.md (base) says not to flag it.

## Inclusion bar

Keep only a finding that will fail to compile or parse, will produce wrong results, or breaks a repo rule you can quote exactly. Code that won't compile or parse counts when nothing the repo runs before merge (its CI, build, or type checker) would catch it.

## Strictness

- **critical-only**: the bar alone: it fails to compile or parse, gives wrong results whatever the input, or breaks a quoted rule. Critical and Important only; no questions.
- **balanced** (default): the bar, plus a reachable edge case with a concrete trigger you can name (an empty list, a boundary value, a retry, a second call). Critical and Important only; up to 3 questions.
- **thorough**: as balanced, plus Minor findings: real, low impact, still never style.

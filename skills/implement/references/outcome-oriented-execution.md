# Outcome-oriented execution

In a rewrite or migration planned in several steps, converge on the end state instead of keeping each intermediate step green with throwaway compatibility code. Shims written to keep step two of five stable tend to stay for years.

- Write down the steps and say which checks may be red between which steps, and why. Planned breakage is fine when it is scoped to those steps and reversible.
- While migrating, keep running the high-signal checks on the area you are touching (its test file, the type check on the touched module) after each step.
- At the end everything is green: the full test suite, type check, lint, build, and one run of each changed command, job, or server that no check covers.

A single change outside such a plan goes test-first and stays green.

**Test:** the final diff has no adapter, alias, or dual code path that exists only to bridge two steps.

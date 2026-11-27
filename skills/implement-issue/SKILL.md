---
name: implement-issue
description: Use when the user asks to implement, fix, or resume one specific issue or ticket on any tracker, such as "implement #42", "pick up PROJ-118", "carry on with #42", or when another skill hands off one issue to build.
compatibility: Needs git, a way to read the issue's tracker and to open pull or merge requests on the code host (a CLI such as gh, glab, acli, az, or tea, a tracker MCP server, or the REST API), the project's own test and build tooling, and the test-driven-development skill from the same plugin (pr-ship, when the user asks to merge a GitHub PR). Uses a reviewer subagent and a question tool (AskUserQuestion or the harness's equivalent) when the harness has them.
---

# Implement issue

One issue in, one branch and one pull request out. The issue is the **contract**: its acceptance criteria say what gets built, and you decide only how. Anything it doesn't ask for (a refactor you'd like, a bug you spot, the next issue's work) goes in the PR as a follow-up, never into the diff: reviewers check the PR against the issue, and every unrequested line is one they must work out the intent of.

The **tracker** holds the issue (GitHub, GitLab, Jira, Linear, Azure Boards, …); the **code host** holds the repository and takes the **PR** (a merge request on GitLab). Often one service is both; with Jira or Linear they differ. [references/trackers.md](references/trackers.md) has each one's commands, link syntax, and pitfalls: read the parts for yours before the first call.

Whatever you tell the user or write in the PR about what the code does cites its evidence: a file:line, or a command you ran and its output. A suspicion you haven't checked is either checked first or labelled as one; a confident wrong claim costs the reader more than silence.

Every run ends with exactly one status, as the reply's last line: `STATUS: <status> — <short reason>`.

| Status | When |
| --- | --- |
| `DONE` | The PR is open, every automated check in its checklist is met, and full verification matches or beats the baseline. Concerns and manual checks are listed in the reply. |
| `NEEDS_CONTEXT` | A person must answer or decide: missing criteria, open questions, the issue and the code disagree, a breaking or out-of-scope change. |
| `BLOCKED` | Something outside the conversation must change first: an unmerged dependency, the same failure after two attempts, tooling you can't run. |

## Progress lives in the PR

A later session resumes from the PR, not from this conversation. Its body holds the **checklist** (each acceptance criterion and definition-of-done item, mapped to the check that proves it) and the **Decisions** the user made. Tick an automated item only once its test passed and the commit is pushed; a ticked box is a claim the reviewer relies on.

**Resuming.** Look for this issue's open PR on the code host first: one whose branch, title, or description carries the issue reference, or one the tracker lists as linked; else a branch with the reference in its name. If there is one, check out its branch and read its body (and any comment the body points to) and `git log`; trust those over any memory of the work. Decisions recorded there are settled. Run the baseline (step 2), untick any item whose test now fails, and continue from the first unticked automated item.

## 1. Find, read, and gate

**Find the tracker** from the reference, the project's docs (README, CONTRIBUTING, AGENTS.md or CLAUDE.md, the PR template), and the git remote, as trackers.md's first table shows, and reach it with the first tool that works: an authenticated CLI, its MCP server, or the API. When nothing reaches it, ask the user to paste the issue with its comments and links, and say which checks that leaves to them (blockers, status).

Read the whole issue, with its comments: they can amend the scope, and the latest word from a maintainer wins. Read every spec, ADR, design, or doc it links, and every file it names.

Stop before anything else when:

- **No acceptance criteria**, or none a person could check ("make it clearer", "clean up X"): `NEEDS_CONTEXT`. Say what's missing and propose criteria you'd use, each checkable, so the author is one edit from a startable issue. Don't build on your own proposal: what gets built is the author's call.
- **No way to verify**: no test runner and no observable outcome you or a person could check. `NEEDS_CONTEXT`, saying what would make it checkable.
- **Not one PR of work**: the issue is closed or done; say so and ask which issue to take. A parent (an epic, a tracking issue) whose work lives in its children goes to the implement-issues skill, which works through them.
- **Someone else's**: it is assigned to anyone but the user or the account your tracker tool is signed in as. Ask whether to take it over.

Done when you hold the criteria, the scope (in and out), and every linked doc and named file.

## 2. Check the ground

- **Dependencies.** Every issue this one is blocked by (its Dependencies section, "after #n" or "depends on PROJ-7" in the text, and the tracker's native blocked-by links) must be closed or done, with its work merged into the default branch: find its PR the way trackers.md finds an existing one, filtered to merged. An open one is `BLOCKED`, naming it; never build on its unmerged branch. One closed as won't-do or cancelled may have left its work undone: the drift check below settles whether the code has it.
- **Drift.** Check each thing the issue assumes (a file, function, behavior, data shape, documented decision) against the up-to-date default branch. Where they disagree, stop with `NEEDS_CONTEXT` and this report:

  ```
  Expected: <what the issue says, quoted>
  Found: <what the code or docs say, with file:line>
  Why it matters: <what building it as written would break or miss>
  How should I proceed? <the options, your recommendation first>
  ```

- **Pattern.** Find the code most like what you'll write (a sibling module, handler, or test) and read it: that's the shape to copy. Note the test layout and naming.
- **Baseline.** Find every check CI runs (its pipeline config, such as `.github/workflows/`, `.gitlab-ci.yml`, or `azure-pipelines.yml`), else the project's scripts: tests, typecheck, lint, build, format. Run them all once on the default branch and record what already fails, so you neither fix it silently nor take it for your own.

Done when dependencies are merged, every assumption holds, and you hold the pattern and the baseline.

## 3. Questions, then the checklist

Read the issue as its toughest reviewer would: criteria that conflict, outcomes it leaves open (empty input, a limit exactly hit, an error path), scope edges, backward compatibility. Ask everything in one round through the question tool, your recommendation first on each, and wait. Ask only what changes what gets built; what the code or docs already settle is yours to settle. No real questions means no questions. With no one to answer (a headless run), end `NEEDS_CONTEXT` with them.

Then write the checklist, in the order the work builds on itself. Each criterion maps to exactly one check:

- **Automated**: the test that proves it (file and test name), or for config, docs, and wiring the narrowest command that does (a build, a typecheck, running the command).
- **Manual**, only when nothing automated can prove it (real devices, a third-party account, production data, visual judgment): the steps a person takes, and why.

Add the issue's definition-of-done items. Done when every criterion has its check.

## 4. Build, one item at a time

**Claim the issue** before the first commit, so others see it's taken: assign it to the account your tracker tool is signed in as (the agent's own account where it has one, else the user's), as trackers.md's Assign row shows. Already the user's or yours, it's claimed. Claiming sets the assignee only: leave the issue's status to the tracker's integration unless the user or repo asks you to move it. If the tracker refuses the assignment, say so in the reply and carry on.

Branch from the up-to-date default branch, named the repo's way with the issue reference in it (the bare key, like `PROJ-118`, where the tracker links branches by key). For each automated item, load the test-driven-development skill and follow it: this skill's baseline and checklist are its ground step and test list. Without that skill: write the test, watch it fail for the reason the criterion names, make it pass, refactor on green.

After each change, run the narrowest check that covers it (the one test file, typecheck or lint on the touched files); the full suite runs at item boundaries and in step 5.

When an item is green, commit only the files you changed, push, and tick it. After the first item, open the PR as a draft, since it's unfinished, with the template below; then it is the progress record. Its first line is the tracker's link-and-close line from trackers.md (`Closes #42` on GitHub), so merging closes the issue where the tracker supports that.

- **Copy the pattern.** Add an abstraction (a base class, a helper module, a dependency) only when nothing existing fits, and say why in the PR.
- **Exactly the issue.** Extras go in the Follow-ups list. A change the criteria don't need is a stop (below).
- **Keep the checks honest.** Never skip, disable, delete, or loosen a test, lint rule, or type check to get green: no `.skip`, no `eslint-disable`, `@ts-ignore`, `# type: ignore`, or `#[allow]`, no lowered thresholds or coverage, no expected value changed to match the output, no `--no-verify`. An existing test the issue makes wrong is updated as that item's red step and listed under Deviations; anything else red is a bug in your change.

## Stop rules

A precise stop beats a PR built on a guess. When one fires, leave the branch at its last green commit, pushed, note the stop in the PR if one is open, report, and end with the status.

| Trigger | Report | Status |
| --- | --- | --- |
| The issue and the code or docs disagree | the drift report (step 2) | `NEEDS_CONTEXT` |
| A breaking change (public API, schema, config, CLI, behavior other callers rely on) or a change outside the issue's scope | the change, why the criteria need it, the options with your recommendation | `NEEDS_CONTEXT` |
| The same failure after two different attempts | the exact error, each attempt and why it failed, your best hypothesis | `BLOCKED` |
| A dependency isn't merged | the issue and its PR | `BLOCKED` |

An attempt is one hypothesis, changed and run; rerunning the same thing is not a second attempt. A small ambiguity the code settles is not a stop: decide it and record it under Decisions as `<what> — <why>`.

## 5. Verify

1. **Full verification.** Rerun every baseline check on the final tree; a run from earlier in the session doesn't count. Match or beat the baseline, and name any check still red.
2. **Spec review.** Read the diff from the default branch (`git diff origin/<default>...HEAD`), not your memory of it, against each checklist item: **met** (its test seen passing), **not met**, or **manual**. Then look for **extra** (in the diff, not in the issue) and **misread** (built, but not what the criterion means). Not met or misread goes back to step 4; extra comes out.
3. **Quality review**, a separate pass after the spec review. Give a reviewer subagent the issue link, the base SHA and the diff command, and the repo's conventions files; ask for correctness bugs, missed edge cases, departures from the repo's patterns, dead code or leftover debugging, weak tests, and docs describing changed behavior that weren't updated, each with file:line and a confidence from 0 to 100, reporting only 80 and up and nothing that predates the branch. Tell it the PR body and your reasons are claims, not evidence, and that you just ran the full verification, so it reads the diff and the code around it instead of rerunning the suite. Without subagents, make the pass yourself, re-reading the diff cold. Fix confirmed findings within scope and rerun full verification; the rest become follow-ups.

Done when full verification is at or above the baseline, every item is met or manual, and the review's in-scope findings are fixed.

## 6. Finish

Write the PR body's final form, inside the repo's PR template if it has one (trackers.md says where each code host keeps it). Leave it a draft or mark it ready the way the user and repo open PRs; for a draft, tell the user it waits on them. Merge only when the user asked to: on GitHub, load the pr-ship skill and run it on this PR; elsewhere, use the code host's ready, checks, and merge commands from trackers.md, merging once its required checks and approvals pass, never around them.

Reply, dropping empty lines:

```
<what changed, one line> — <PR link>
Criteria: <n> met · <m> manual · <k> not met
Verified: <checks and results, against the baseline>
Manual checks for you: <each>
Decisions · Deviations · Follow-ups · Concerns: <each>
STATUS: DONE — <reason>
```

## PR body

```md
<the tracker's link-and-close line, from trackers.md>

## Checklist
- [x] <criterion> — `<test name>` in `<file>`
- [ ] <criterion> — manual: <steps> (<why it can't be automated>)
- [x] Docs updated where behavior changed

## Verification
Automated: `<command>` → <result> (baseline: <what already failed, or clean>)
Manual, not done: <each manual check, for the reviewer>

## Decisions
<each question and the user's answer, and each small call you made: what — why>

## Deviations from the issue
<what differs from the issue and why, or none>

## Follow-ups
<extras noticed and not built, or none>
```

Manual items stay unticked until the person who did them says so: you didn't do them, and a ticked box tells the reviewer someone did.

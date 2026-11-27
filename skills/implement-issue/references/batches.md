# Several issues or a parent

You own the **plan**: which issues run, grouped into **batches**, and the **gate** before each next batch. Each issue belongs to its **runner**, one single-issue run of this skill in its own thread or subagent, which reads the issue, asks its questions, builds it, opens its PR, and merges it when asked. Route every action on an issue, its code, or its PR through its runner, so one set of rules governs each issue.

Reach the tracker with the commands in [trackers.md](trackers.md) (Read, Blocked by, Parent or children, existing PR). The tracker is the state: re-derive it every run, including "carry on" in a new session.

## 1. Collect

Expand the goal into issues: a parent stands for its open children, recursively. A parent with one open child left is still a goal here, a one-issue batch followed by step 5.

For each issue, record what the plan needs, from its text and a glance at the code:

- **State**: done (closed, PR merged), in flight (open PR), or to do.
- **Blockers**: native links, plus "after #n" or "depends on" in the text.
- **Footprint**: the files and modules it names or will clearly touch.

Done when every issue has all three.

## 2. Plan

Pick the mode yourself: the first one below that the harness supports. The plan names it; the go covers it.

1. **Threads**: the harness can start top-level threads the user can open and talk to. One thread per issue, so a batch may hold several issues.
2. **Subagents**: otherwise. One subagent per issue, one at a time, so each batch is one issue.
3. **Inline**: no subagents either. Run the skill's single-issue steps yourself, one issue per batch.

Order the batches: an issue goes after every batch holding one of its blockers, since runners build on merged code. In threads mode, issues share a batch only when neither blocks the other and their footprints are disjoint; overlapping PRs conflict at merge, so when unsure, split. In-flight issues go first; otherwise keep the tracker's order.

Show the plan as markdown the harness renders, shaped like this example:

**Plan for #8 Loan reminders** (threads)

- **Batch 1**: #12 Due-date email, #15 Reminder settings page — separate modules, neither blocks the other
- **Batch 2**: #19 Weekly digest — after #12

Done: #10 · Waiting outside the goal: #21 (blocked by #30)

Each batch starts once every PR of the one before is merged and you say go.

Done when the user gives the **go**: their answer to the plan, or an explicit "just start" in the request. Naming the issues alone is not a go. With no one to answer, stop at the plan.

## 3. Run a batch

Start every runner of the batch at once, each with this brief and nothing more; its own run does the reading:

```
Use the implement-issue skill on <issue link>, this issue alone.
Part of <goal>, planned by another run. Decisions already made for it: <each, or none>.
Work in your own worktree; leave other issues' branches alone.
```

- **Threads**: create each thread on its own worktree from the up-to-date default branch. The user answers a runner's questions in its thread. Wait with the harness's wait tool.
- **Subagents**: a subagent can't reach the user, so its questions come back with `NEEDS_CONTEXT`. Put them to the user in one round, then start a fresh runner with the answers as decisions; it resumes from its PR.

Done when every runner has ended with its STATUS.

## 4. Gate

Report in the plan's markdown, then end your turn:

**Batch 1 of 2 for #8 Loan reminders**

- #12 Due-date email — `DONE` — [PR #51](https://github.com/acme/library/pull/51)
- #15 Reminder settings page — `NEEDS_CONTEXT` — should snoozing be per loan or per member?

Next: batch 2 (#19) once #15 is answered, its PR and PR #51 are merged, and you say go.

The gate opens when every issue of the batch has its PR merged, checked on the code host, and the user says go. Until then, name what's missing and wait.

- An issue that ended `NEEDS_CONTEXT` or `BLOCKED` keeps the gate shut; rerun its runner once the user answers or the blocker clears.
- A merge request or review feedback goes to that issue's runner: its thread, or a fresh runner with the request as a decision.
- If the user drops an issue, name the later issues it blocks; they wait for the user's call.

Once the gate opens, collect again, and show the plan again only if it changed.

## 5. Close the parent

When every child of a parent is done (the goal's parent, or a nested parent found while expanding it, innermost first), check each of that parent's own criteria against the merged work, citing the PR or file:line.

- **All met**: close the parent with a comment listing the merged PRs, unless the tracker already did.
- **Gaps**: list each unmet criterion, offer to file it with the create-issues skill, and leave the parent open.

Done when each such parent is closed or its gaps are in front of the user.

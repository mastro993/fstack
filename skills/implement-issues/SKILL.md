---
name: implement-issues
description: Use when the user asks to implement several issues, or a parent issue (an epic or tracking issue) through its sub-issues, such as "implement #12, #15 and #19", "work through the sub-issues of #40", or "start the next batch".
compatibility: Needs the implement-issue skill from the same plugin, plus create-issues to file a parent's gaps. Uses threads when the harness can start them, else subagents.
---

# Implement issues

A thin wrapper around the implement-issue skill. You own the **plan**: which issues run, grouped into **batches**, and the **gate** before each next batch. Each issue belongs to its **runner**, one implement-issue run in its own thread or subagent, which reads the issue, asks its questions, builds it, opens its PR, and merges it when asked. Route every action on an issue, its code, or its PR through its runner, so one set of rules governs each issue.

Reach the tracker with the commands in implement-issue's [references/trackers.md](../implement-issue/references/trackers.md) (Read, Blocked by, Parent or children, existing PR). The tracker is the state: re-derive it every run, including "carry on" in a new session.

## 1. Collect

Expand the goal into issues: a parent stands for its open children, recursively. If one issue remains, hand it to implement-issue; the rest of this skill doesn't apply.

For each issue, record what the plan needs, from its text and a glance at the code:

- **State**: done (closed, PR merged), in flight (open PR), or to do.
- **Blockers**: native links, plus "after #n" or "depends on" in the text.
- **Footprint**: the files and modules it names or will clearly touch.

Done when every issue has all three.

## 2. Plan

Pick the mode:

- **Threads**: the harness can start top-level threads the user can open and talk to. One thread per issue, so a batch may hold several issues.
- **Subagents**: otherwise. One subagent per issue, one at a time, so each batch is one issue.
- **Inline**: no subagents either. Run implement-issue yourself, one issue per batch.

Order the batches: an issue goes after every batch holding one of its blockers, since runners build on merged code. In threads mode, issues share a batch only when neither blocks the other and their footprints are disjoint; overlapping PRs conflict at merge, so when unsure, split. In-flight issues go first; otherwise keep the tracker's order.

Show the plan:

```
Plan for <goal> (<mode>)
Batch 1: #12 <title>, #15 <title> — <why they can run together>
Batch 2: #19 <title> — after #12
Done: #10 · Waiting outside the goal: #21 (blocked by #30)
Each batch starts once every PR of the one before is merged and you say go.
```

Done when the user gives the **go**: their answer to the plan, or an explicit "just start" in the request. Naming the issues alone is not a go. With no one to answer, stop at the plan.

## 3. Run a batch

Start every runner of the batch at once, each with this brief and nothing more; its own implement-issue run does the reading:

```
Use the implement-issue skill on <issue link>.
Part of <goal>. Decisions already made for it: <each, or none>.
Work in your own worktree; leave other issues' branches alone.
```

- **Threads**: create each thread on its own worktree from the up-to-date default branch. The user answers a runner's questions in its thread. Wait with the harness's wait tool.
- **Subagents**: a subagent can't reach the user, so its questions come back with `NEEDS_CONTEXT`. Put them to the user in one round, then start a fresh runner with the answers as decisions; implement-issue resumes from its PR.

Done when every runner has ended with its STATUS.

## 4. Gate

Report, then end your turn:

```
Batch <k> of <n> for <goal>
- #12 — <STATUS> — <PR link, or the questions or blocker>
Next: batch <k+1> (<issues>) once <PR links> are merged and you say go.
```

The gate opens when every issue of the batch has its PR merged, checked on the code host, and the user says go. Until then, name what's missing and wait.

- An issue that ended `NEEDS_CONTEXT` or `BLOCKED` keeps the gate shut; rerun its runner once the user answers or the blocker clears.
- A merge request or review feedback goes to that issue's runner: its thread, or a fresh runner with the request as a decision.
- If the user drops an issue, name the later issues it blocks; they wait for the user's call.

Once the gate opens, collect again, and show the plan again only if it changed.

## 5. Close the parent

When every child of a parent goal is done, check each of the parent's own criteria against the merged work, citing the PR or file:line.

- **All met**: close the parent with a comment listing the merged PRs, unless the tracker already did.
- **Gaps**: list each unmet criterion, offer to file it with the create-issues skill, and leave the parent open.

Done when the parent is closed or its gaps are in front of the user.

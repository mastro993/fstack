---
name: create-issues
description: Use when agreed work should become issues or tickets on the project's tracker, such as "open issues for this spec", "break this plan into tickets", "file this bug", or another skill's handoff that ends in issues.
compatibility: Needs the pr-babysit skill from the same plugin to land docs. Works best with gh 2.94+ (native sub-issue and blocked-by links) or a tracker MCP, and a question tool (AskUserQuestion or the harness's equivalent).
---

# Create issues

You turn an implementation **contract** into tracker issues. The contract is what the user has already settled: a spec, a plan, ADRs, prototypes, a bug diagnosis, or the conversation itself. You decide whether to split it and how, and nothing about what gets built. A gap or contradiction in the contract goes back to the user as a question, never into an issue as a guess; a requirement you can't place is surfaced, never dropped.

Splitting is never the goal. Each issue is a mergeable, reviewable, independently verifiable unit of work. **Default to one issue**, and split only when a trigger below fires; a split you can't name a trigger for is an error, however thorough it feels.

When another skill hands off to this one, it names the contract and anything extra each issue carries; take it from step 1 and hand back after step 7.

## Thresholds

Defaults. A project's own numbers (in its CLAUDE.md, AGENTS.md, or contributing docs) win.

| Tier | Signals | Output |
| --- | --- | --- |
| XS | ≲ 100 non-test lines, 1 module, no open questions | 1 issue, minimal template |
| S | ≲ 400 non-test lines, ≲ 10 files, one deployable | 1 issue, full template |
| M | Above S, or a split trigger fires | Parent tracking issue + 2–5 sub-issues |
| L | Several modules or repos, release ordering, or residual unknowns | Parent + phased plan, typically 5–10 sub-issues |
| XL | Would need more than ~10 issues, or mixes independently shippable features | No issues: recommend splitting the contract |

The tier is a first estimate. A trigger can move S work to M; nothing splits XS work.

## Split triggers

The only valid reasons to split, each named on the issue it creates:

- **Size** above S: vertical slices, happy path first, then variants, error paths, and business rules (SPIDR: spike, paths, interfaces, data, rules).
- **Refactor first**: the change needs a behavior-preserving refactor to fit; it is its own issue, before the feature.
- **Variants**: the contract defines variants with their own acceptance criteria (data types, flows, platforms); one issue each, after the base path.
- **Release ordering** (backend before client, data migration, breaking change): expand, migrate consumers, then contract.
- **Unknowns**, L only: a time-boxed spike whose output is a decision or ADR, not merged production code.
- **Feature flag**: the flag-removal issue is created now, with the rest.

These are never issues of their own: a layer with no verifiable outcome ("create the store", "build the UI"), "write tests" or "update docs" (every issue's definition of done carries them), anything that leaves main broken or unreleasable once merged alone, anything too small to validate by itself.

**Bugs** are one issue: a failing test that reproduces the bug, plus the fix. Split only when a mitigation (kill switch, guard) must ship before the root-cause fix, a non-trivial refactor comes first, data needs repair or migration, or observability must come first to understand the problem.

## 1. Read the contract

- Read every file the contract includes, and extract its requirements as a numbered list (R1, R2, …), each with its source. Note every file an issue will link: spec sections, ADRs, prototypes, screenshots.
- Find the tracker from the project: the git remote with `gh repo view`, or a tracker MCP. With none reachable, say so, give the plan from step 3 in the reply, and stop there.
- Read the tracker's open issues for ones that already cover part of the work, and its labels.

Done when every requirement has a number and a source, and you know the tracker, its overlapping issues, and the files to link.

## 2. Classify

Estimate the diff, the files, and the modules from the code the contract touches, pick the tier, and list the triggers that fire. Calibrate against [references/examples.md](references/examples.md), one worked example per tier.

At **XL**, stop: file nothing, and reply with why the contract is too big and the cut lines that would make it separate contracts.

Done when you hold a tier, the reason for it, and each fired trigger (or "none: one issue").

## 3. Draft the plan

- **XS, S**: one issue; no parent, no dependency graph.
- **M**: a parent tracking issue and sub-issues. The first sub-issue is the **tracer bullet**, the thinnest path through every layer the feature touches, behind a flag when users would see it; the rest enrich it.
- **L**: as M, in phases (spike, preparatory refactor, tracer bullet, enrichment, hardening, flag cleanup), with the dependency graph and which issues can run in parallel. Spikes come first; the parent says the plan is re-evaluated once they close.

When the contract proposes slices, keep each one a trigger justifies, merge the rest, and say in the plan what you merged and why. Write each issue to the template below, for someone who never saw this conversation.

## 4. Self-check

Check the plan, fix it, and check again until all hold:

1. **Coverage**: a traceability matrix maps every requirement to exactly one issue, with no gaps and no duplicates.
2. Every issue merges alone with CI green and main releasable.
3. Blockers are explicit. Issues are marked parallel only when they touch disjoint files or modules, since parallel agents may pick them up at once.
4. The issue count is within the tier's range; if not, re-plan or move the tier.
5. Every split names its trigger.

## 5. Confirm

Show the tier and why, the issues (title, trigger, blocked by, parallel with), the traceability matrix, and any gap as a question. Ask through the question tool whether to file it, with "File these" first, and wait for an explicit yes; a correction updates the plan and comes back through step 4. A user who already dictated or approved these exact issues and asked to file them has given that yes; choosing issues as a delivery, or approving the spec or plan they come from, has not, since the user hasn't seen the issues.

## 6. Land the linked files

Issues outlive branches: a link to a docs branch dies once it merges and is deleted, and a link to the default branch drifts as the docs change. So every linked file lands on the default branch first, and each issue links it at a fixed commit there.

1. Skip to step 3 of this list when every linked file is already on the remote's default branch.
2. Commit the files on a branch, push it, and open a pull request for it the way the user and the repo open theirs (draft or ready for review, the PR template); say in its body that the issues follow its merge. Tell the user in a line, with the link, that the issues wait for the merge, and, for a draft, that it waits on them to mark it ready. Then load the pr-babysit skill and run it on that PR, merging only if the user asked. If the PR closes unmerged, or the push fails, ask the user how to go on.
3. Update the local default branch and re-read the linked files as merged, since review may have changed them. Take the full SHA of its head (`git rev-parse origin/<default-branch>`) and link every file as `https://github.com/<owner>/<repo>/blob/<sha>/<path>`, or the tracker's equivalent.

A file that can't land (git-ignored, local to this machine) can't be linked: describe it in words, and attach images after opening each one to check it shows nothing sensitive (secrets, real personal data, internal-only identifiers).

## 7. File and reply

Create the parent first, then the sub-issues in dependency order, blockers first, so each names its blockers by number. Link them natively as well: on GitHub, `gh issue create --parent <n> --blocked-by <n>` (gh 2.94+), or the REST endpoints on older gh (`POST repos/<owner>/<repo>/issues/<n>/sub_issues` with `sub_issue_id`, `.../dependencies/blocked_by` with `issue_id`, both the database `id`, not the number). Use the project's labels. Where an issue already covers part of the work, edit it to match instead of opening another.

Reply with the issue links, and for M and L the order: the tracer bullet first, then which issues can run in parallel, and why.

Done when every planned issue exists exactly once with its links, parent, and blockers.

## Issue template

```md
## Context
<what this delivers, in the project's terms>
> <the contract excerpt it implements, quoted>
Contract: <link to the section> · ADRs: <links> · Prototype: <link>

## Scope
In: …
Out: … (covered by #n)

## Acceptance criteria
- [ ] Given …, when …, then …

## Implementation notes
Likely touched: `src/…`. The approach, the decisions that constrain it, known pitfalls; the details are the implementer's.

## Dependencies
Blocked by: #n · Parallel with: #m · Feature flag: `name` (or none)

## Definition of done
- [ ] Tests for every acceptance criterion
- [ ] Docs updated where behavior changed
- [ ] Flag state: …

Tier: M · Trigger: <the trigger behind this split>
```

Title each issue with the outcome ("Members can renew from the reminder email"), not the activity. XS issues keep only Context, Acceptance criteria, and Definition of done.

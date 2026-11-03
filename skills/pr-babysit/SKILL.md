---
name: pr-babysit
description: Use when the user asks to monitor, watch, babysit, shepherd, or keep an eye on a pull request through CI and code review, or to "get this PR green", "land this PR", "fix CI and address the review comments", or "tell me when CI finishes". Waits on GitHub, fixes failing checks, answers and addresses review comments (human and bot), pushes, re-requests review, and reports when the PR is ready to merge.
compatibility: Needs the gh CLI (authenticated), git, python3, and a checkout of the PR's repository to push fixes from.
---

# PR babysit

You are the PR's caretaker until it is ready to merge. Wait on GitHub without burning turns, react to each failed check or new review comment, push fixes, and tell the user when the PR is ready or when you need them.

- **Ready**: open, every check passed, review approved (or none required), mergeable, and no review thread waiting on a reply. Draft PRs can't be ready; say so, don't flip them.
- **Watch-only**: the user asked only to be told ("let me know when CI finishes", "don't push anything"). Then you diagnose and report, but you edit, commit, push, and comment on nothing.

`scripts/pr_watch.py` (in this skill's directory) does the GitHub reads, so every check of the PR costs one command:

- `python3 <skill-dir>/scripts/pr_watch.py snapshot [PR]` prints state, failing checks, threads awaiting reply, a `READY:` line with the blockers, and anything new since you last looked.
- `python3 <skill-dir>/scripts/pr_watch.py wait [PR]` polls every 30 s and exits as soon as something new happens (check failed, all checks passed, new review or comment, merge conflict, PR closed), printing the events and a fresh snapshot. With nothing new it exits after 25 min with `NO CHANGE`.

Whatever either command printed counts as seen, so `wait` never repeats it. Comments by the gh-authenticated account are always treated as seen, since they are your own replies; the user gives you instructions in chat, not on GitHub.

## 1. Set up

1. **Find the PR.** Use the number or URL given; otherwise the PR for the current branch (`gh pr view --json number,url`). If there is none, ask.
2. **Take the snapshot.** Run `snapshot` and read it fully. Anything already failing or awaiting a reply is your first piece of work, before any waiting.
3. **Get a checkout you can push from** (skip in watch-only). If the user's working tree is clean and already on the PR's head branch, work there after `git pull --ff-only`. Otherwise leave it alone: uncommitted changes or another checked-out branch are the user's work in progress, and switching, stashing, or committing over them isn't yours to decide. Work in a separate worktree instead:
   ```bash
   git fetch origin <head branch>
   git worktree add --detach ../<repo>-pr-<n> origin/<head branch>
   ```
   and push from it with `git push origin HEAD:<head branch>`. Detached, because the branch may already be checked out in the user's tree. Ask the user only if a worktree isn't possible. For a PR from a fork, check `maintainerCanModify`; if you can't push, fall back to watch-only and tell the user why.

## 2. Wait

Prefer, in order:

1. **A host PR-watch tool**, if your environment has one (for example `watch_pull_request`). It wakes you on the same events without polling. Follow that tool's own rules for ending your turn and re-arming.
2. **`wait` as a background command** (Bash with `run_in_background`). You get one notification when it exits; handle the events, then start `wait` again. End your turn while it runs instead of sleeping or looping, so the user can still talk to you.
3. **`wait` in the foreground** with `--timeout 540`, only when background commands aren't available, re-running it after each `NO CHANGE`.

On `NO CHANGE`, re-arm without messaging the user unless something has been stuck for a long time (a check pending for over an hour, a reviewer silent all day); then tell them once.

## 3. Handle a failed check

1. **Read the failure once.** For GitHub Actions, take the run ID from the check link (`/actions/runs/<id>/job/...`) and run `gh run view <id> --log-failed`. Read it fully; don't refetch the same run's log. For external checks (Vercel, CircleCI, Buildkite), follow the link; if you can't get the log, report the check and its link.
2. **Decide what kind of failure it is.**
   - *Caused by the PR's code or tests*: reproduce locally with the project's own command when feasible, fix the root cause, and rerun that command before pushing. Don't skip, delete, or loosen a test to make it pass; if the test is right and the fix isn't obvious, ask.
   - *Infrastructure* (runner lost, network timeout, registry 5xx, a known-flaky test unrelated to the diff): `gh run rerun <id> --failed`, once per check per commit. A second failure is not flakiness; treat it as real.
   - *Also failing on the base branch* (check `gh run list --branch <base> --workflow <name>`): not this PR's fault. Report it and don't fix it here unless the user asks.
3. **Stop after two failed attempts** at the same check. Report what you tried and ask, rather than piling up speculative commits.

## 4. Handle review feedback

Read every new comment in the context of the code it points at (`gh pr diff`, the file at the line), then sort it:

- **Actionable and clear**: make the change. If several comments touch the same thing, fix it once.
- **A question**: answer it in the thread from what the code actually does. No code change unless the answer reveals a bug.
- **Bot reviewers** (Copilot, CodeRabbit, Pullfrog, any `[bot]` account): check the claim against the code before acting; bots often flag things the types or callers already rule out. If it's real, fix it like any other comment. If it's a false positive, reply in one or two sentences saying why, citing the code, and change nothing.
- **Needs the user**: design changes, scope growth, disagreement with a human reviewer, or anything you'd be guessing at. Ask the user and keep the watch running meanwhile. Pushing back on a human reviewer is the user's call, not yours, because it speaks for them in public.

Leave threads unresolved: resolving is the reviewer's way of saying they're satisfied.

## 5. Push and close the loop

1. Run the project's relevant checks locally (tests, lint, typecheck) on what you changed.
2. Check `git status` and stage only the files you meant to change (`git add <paths>`, never `-A` or `.`). Running tests and builds leaves artifacts (`__pycache__/`, `dist/`, coverage files) that a broad add sweeps into the PR, and once pushed they stay in its history.
3. Commit with a message that says what changed and why, following the repo's commit style. One commit per round of fixes is easier for reviewers to follow than one per comment.
4. Pull before pushing in case someone else pushed: `git pull --rebase`, or in a detached worktree `git fetch origin <head branch> && git rebase origin/<head branch>`. Push without force. If the base branch moved and the PR now conflicts, resolve mechanical conflicts with the repo's convention (rebase plus `--force-with-lease` only on a branch nobody else commits to; otherwise merge the base in). Ask about conflicts that need judgment.
5. Reply on each thread you addressed, saying what changed and the short SHA ("Fixed in a1b2c3d: switched to `csv.writer` so commas in names are quoted."):
   ```bash
   gh api graphql -f query='mutation($id: ID!, $body: String!) {
     addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $id, body: $body}) { comment { url } }
   }' -f id=<thread id from the snapshot> -f body='<reply>'
   ```
   Top-level comments get a top-level reply: `gh pr comment <n> --body '<reply>'`.
6. When every thread from a human reviewer who requested changes or asked questions has a reply, re-request their review: `gh pr edit <n> --add-reviewer <login>`. Bots usually re-review on push by themselves; don't re-request them.
7. Tell the user in a line or two what you fixed and pushed, then go back to waiting.

## 6. Finish

Stop watching when:

- **Ready**: say so, with the PR link and a short list of what you did along the way. Don't merge unless the user asked you to merge in this request, and don't mark a draft ready for review.
- **Merged or closed** by someone else: report it and stop.
- **Blocked on the user** and there's nothing else to wait for (for example, the only open item is a question you asked them): ask, and say the watch will resume once they answer.
- **Watch-only and the thing they asked about happened**: report it. For a failed check, include which check, the failing test or error quoted exactly, and your read of the cause, but change nothing.

When you stop, end any background `wait` you started (and unwatch with the host tool, if you used one), so nothing keeps waking you after the job is done, and remove any worktree you created (`git worktree remove <path>`).

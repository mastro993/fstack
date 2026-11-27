---
name: pr-open
description: 'Use when the user asks to open a pull request, or to write or rewrite a PR title or description, such as "make a draft PR for this branch", "PR this for #42", or "write the PR description", or when another skill hands off a PR to open.'
compatibility: Needs git and the gh CLI (authenticated, new enough for `gh pr create --attach`). Captures previews with the harness's browser or preview tool, or an installed headless browser (playwright-cli, browser-use, Chrome).
---

# PR open

Turn the branch into a pull request a reviewer understands in a minute: a title that says what changes, and a body that shows why, what, and how to check it. The job ends when the PR is open, or when the title and body are shown to a user who asked only for the text.

## 1. Read the change

1. **Base and state.** The base is the branch the user named, else the default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`). Run `git fetch origin` and `git status -sb`. Look for this branch's PR: `gh pr view --json number,url,state,isDraft,title,body`. An open one gets its title and body rewritten with `gh pr edit`.
2. **Uncommitted work.** On the base branch, move the work to a new branch named the repo's way. Commit the files that belong to the change with conventional commit messages, and ask when it is unclear which do. Unrelated changes stay in the working tree; mention them in the reply.
3. **The change.** Read `git log --format='%h %s%n%b' origin/<base>..HEAD`, `git diff --stat origin/<base>...HEAD`, and the full diff. The PR describes this diff.
4. **The issue.** It resolves an issue when the user names one, the branch name carries one (`fix/42-…`, `feat/PAY-118-…`), or a commit says `Closes #42`. Read a GitHub issue with `gh issue view <n> --json title,body,labels,comments`; it usually holds the why and, for a bug, the repro. A key-based ticket (`PAY-118`) you can't read keeps its key, and the why comes from the user and the commits. Tickets come only from these sources. The body's first line closes a GitHub issue (`Closes #<n>`, one keyword per issue) when the base is the default branch, and refers to it (`Refs #<n>`) otherwise; a tracker key becomes a link to its ticket when you know the URL.
5. **The template.** `pull_request_template.md` (any case) in `.github/`, the repo root, or `docs/`, or a `PULL_REQUEST_TEMPLATE/` folder in one of those. With several templates, take the one the change's type fits and say which.
6. **Conventions.** The title format the repo enforces or documents: a PR-title lint in `.github/workflows/`, commitlint config (its `scope-enum` lists the allowed scopes), CONTRIBUTING. Recent merged titles (`gh pr list --state merged --limit 15 --json title`) show the scopes in use.

Done when you can state the base, what the diff does in a sentence, the issue it resolves (or none), and the template (or none).

## 2. Title

`<type>(<scope>): [<ticket>] <summary>`, a Conventional Commits title.

- **Type** from what the diff does: `feat` adds behavior a user or caller can use, `fix` corrects behavior, `refactor` keeps behavior, and `perf`, `docs`, `test`, `build`, `ci`, `style`, `chore`, `revert` as usual. A breaking change gets `!` before the colon (`feat(api)!:`).
- **Scope** is the domain the change lives in: a scope the repo lists or already uses, else the module, package, or feature most of the diff touches. A change spread across unrelated areas goes without one.
- **Ticket**, when the PR resolves one: `[#42]` for a GitHub issue, `[PAY-118]` for a tracker key, `[#42, #57]` for several.
- **Summary** in the imperative present, the way you'd finish "This PR will…": `add`, `fix`, `resolve`, `implement`, `remove`. Lowercase, ending without a period, about 70 characters for the whole title. Name the behavior a reader will notice: `fix(auth): [#42] reject expired refresh tokens`.

A title format the repo enforces (a lint, a documented rule) wins over this one, since a title CI rejects helps no one; say which rule you followed.

## 3. Body

Fill the repo's template when it has one: keep its headings, order, and checkboxes, follow and then delete its HTML-comment guidance, and write `n/a` under a heading the change has nothing for. Put each piece below under the heading it fits; a piece with no fitting heading gets a short section of its own after the template's. Without a template, use the default below with the sections the change has content for.

**Words are the last resort.** A reviewer takes in a picture faster than a paragraph, so reach first for:

- **A mermaid diagram** when the change touches how parts relate: a new or changed flow (`flowchart`), calls between services or components (`sequenceDiagram`), a state machine (`stateDiagram-v2`), a data model (`erDiagram`), or the blast radius as a graph. Keep it to the nodes the change touches, and draw one when it replaces a paragraph.
- **A `diff` block** when the point is a before and after of something small: a signature, a config value, a rule, a CLI output, a call tree, a file tree. Lift the few lines that carry the change, or sketch them as pseudocode; the Files tab holds the rest.
- **A table** when items share attributes: before/after previews, endpoints and their status codes, options and defaults.

The prose that's left is short, plain sentences in the project's own terms, written for a reviewer who hasn't seen the conversation. Group changes by behavior. Every claim about behavior comes from the diff, a test, or a command you ran.

**Blast radius** goes in the What section: what else the change can affect. Find it by searching callers and consumers of what changed (`git grep` every changed function, type, route, env var, schema field, and config key, until each one's users are accounted for), and list them: callers that get the new behavior, public APIs, data migrations, config defaults, feature flags, and anything shipped to other teams or clients. Then name what stays as it was where a reader would worry, and whether it's a two-way door (a revert undoes it) or a one-way one (a migration, deleted data, a published API).

**Bugs** get a repro under How to test: the exact steps and inputs that show the bug on the base branch, what happens there, and what happens on this branch. The tester runs it on both and sees the difference.

**How to test** names the automated checks that cover the change (the command and the tests added or changed, with their result when you ran them) and, when a person has to look, the manual steps. Manual checkboxes stay unticked for the person who runs them.

**Previews** belong to a change a person sees on screen: UI, styles, copy, emails, generated images, CLI output. For those, read [references/previews.md](references/previews.md) and capture them yourself, before and after, before you open the PR. Other changes show their before and after in the diff block and the repro, and the body ends at How to test.

### Default template

Use it when the repo has none. The example shows the shape; the content is the change's.

````md
Closes #42

## Why

Expired coupons still apply their discount at checkout, so lapsed promo codes keep costing money (#42).

## What

```diff
  if (!coupon.active) return reject("inactive");
+ if (coupon.expiresAt <= now) return reject("expired");
  return accept(coupon.discount);
```

**Blast radius**

```mermaid
flowchart LR
  checkout["Checkout form"] --> validate["validateCoupon()"]
  admin["Admin API: POST /orders"] --> validate
  validate --> total["Order total"]
```

- Checkout and admin-created orders now refuse expired coupons; orders already placed keep their discount.
- Two-way door: a revert restores the old check.

## How to test

**Automated**: `npm test -- coupons` → 31 passed, including the new `rejects an expired coupon`.

**Manual**
- [ ] Reproduce on `main`: apply coupon `SPRING24` (expired 1 June 2024) at checkout → 20% off applied.
- [ ] Same steps on this branch → "This coupon expired on 1 June 2024", no discount.

## Previews

| Before | After |
| --- | --- |
| ![Checkout with an expired coupon, before](./before-checkout.png) | ![Checkout with an expired coupon, after](./after-checkout.png) |
````

Done when every template heading (or default section) the change has content for is filled, and each behavior claim traces to the diff, a test, or a command you ran.

## 4. Open it

Write the body to a file in a scratch directory, with the preview files beside it. Push with `git push -u origin HEAD`, then:

```bash
gh pr create --base <base> --title "<title>" --body-file <dir>/body.md --attach '<dir>/before-checkout.png#Checkout with an expired coupon, before' [--draft]
```

`--attach`, repeated per file, uploads each image or video and points the body's matching `![…](./…)` reference at it. An existing PR takes the same flags on `gh pr edit`. Open it as a draft or ready for review the way the user and the repo open theirs (their instructions, the calling skill, the user's recent PRs); when nothing says, open a draft, which pings no reviewers until the user marks it ready. Labels, reviewers, and assignees come from the user or the template.

When the user asked only for the text, show the title and body in place of this step.

Done when a read-back (`gh pr view --json title,body,url`) shows the title as written, every preview pointing at an uploaded asset, and the mermaid and diff blocks intact.

## Reply

The link and the title, then a line each for what the reviewer should know and what's left to the user, dropping lines that are empty. For example:

**fix(checkout): [#42] reject expired coupons** — https://github.com/readwell-dev/shop/pull/57 (draft)
- Previews: checkout before and after, attached.
- Left to you: the two manual checks, and marking it ready.

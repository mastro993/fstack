---
name: pr-open
description: 'Use when the user asks to open a pull request, or to write or rewrite a PR title or description, such as "make a draft PR for this branch", "PR this for #42", or "write the PR description", or when another skill hands off a PR to open.'
compatibility: Needs git and the gh CLI (authenticated, new enough for `gh pr create --attach`). Captures previews with the harness's browser or preview tool, or an installed headless browser (playwright-cli, browser-use, Chrome).
---

# PR open

Turn the branch into a PR a reviewer understands in a minute. The job ends when the PR is open, or, when the user asked only for the text, when the title and body are in the reply.

## 1. Read the change

- **Base**: the branch the user named, else the default (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`). Run `git fetch origin`. An open PR for this branch (`gh pr view --json number,url,state,isDraft,title,body`) gets rewritten with `gh pr edit`.
- **Uncommitted work**: on the base branch, move it to a new branch named the repo's way. Commit the files that belong to the change with conventional messages, asking when unclear; leave unrelated changes in the tree and mention them.
- **Diff**: `git log --format='%h %s%n%b' origin/<base>..HEAD` and the full `git diff origin/<base>...HEAD`. The PR describes this diff.
- **Issue**: named by the user, the branch (`fix/42-…`, `feat/PAY-118-…`), or a commit (`Closes #42`); tickets come only from these. `gh issue view <n> --json title,body,labels,comments` holds the why and, for a bug, the repro. A tracker ticket you can't read keeps its key; the why comes from the user and the commits.
- **Template**: `pull_request_template.md` (any case) or a `PULL_REQUEST_TEMPLATE/` folder, in `.github/`, the root, or `docs/`. With several, pick by change type and say which.
- **Title rules**: a PR-title lint in `.github/workflows/`, commitlint (`scope-enum`), CONTRIBUTING; scopes in use from `gh pr list --state merged --limit 15 --json title`.

## 2. Title

`<type>(<scope>): [<ticket>] <summary>`, Conventional Commits. A format the repo enforces wins; say which you followed.

- **Type**: `feat` adds behavior, `fix` corrects it, `refactor` keeps it; `perf`, `docs`, `test`, `build`, `ci`, `style`, `chore`, `revert` as usual. Breaking: `feat(api)!:`.
- **Scope**: one the repo lists or uses, else the module most of the diff touches; left out for changes across unrelated areas.
- **Ticket**, when the PR resolves one: `[#42]`, `[PAY-118]`, `[#42, #57]`.
- **Summary**: imperative, lowercase, ending without a period, whole title about 70 characters, naming the behavior a reader notices: `fix(auth): [#42] reject expired refresh tokens`.

## 3. Body

With a repo template: keep its headings, order, and checkboxes, follow then delete its HTML comments, write `n/a` under empty headings, and put each piece below under the heading it fits, else in a short section after the template's. Without one: the default template below, with the sections that have content.

- **Issue line**, first: `Closes #<n>` per GitHub issue when the base is the default branch, `Refs #<n>` otherwise. Another tracker's ticket: `Ticket: [PAY-118](<url>)`, or `Ticket: PAY-118` without a URL, since closing keywords act only on GitHub issues.
- **Why and What**: short everyday sentences for a reviewer who hasn't seen the conversation, in the project's own names. Every behavior claim comes from the diff, a test, or a command you ran. The why comes from the issue, the user, or the commits; when none gives one, write what the diff shows and say in the reply that you inferred it. Add the smallest view that makes the point, one or two at most:
  - mermaid when parts relate (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram`), with only the nodes the change touches;
  - a `diff` block for a before and after of an existing shape: the few lines that carry the change, or a sketched tree or rule;
  - a table for items that share attributes.
- **Merge danger**, prose, after What:
  - **Reversible**: yes, or no when a revert leaves something behind (a migration, deleted data, a published API, sent emails), with the reason in a sentence.
  - **Blast radius**: one paragraph of about three sentences: size (contained, moderate, wide), what else now behaves differently, and what stays as it was where a reader would worry. `git grep` every changed function, type, route, env var, schema field, and config key until each one's callers and consumers are accounted for.
- **How to test**: the command and the tests added or changed, with results when you ran them. Manual steps when a person has to look, each runnable on this branch as written, checkboxes unticked. A bug gets a repro: exact steps and inputs, and the result on the base and on this branch.
- **Previews**, last, for a change seen on screen (UI, styles, copy, emails, generated images, CLI output): capture them per [references/previews.md](references/previews.md) before opening the PR.

Default template (the shape; the content is the change's):

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

## Merge danger

**Reversible: yes.** A revert restores the old check; nothing is stored or migrated.

**Blast radius: moderate.** Checkout and admin-created orders both go through `validateCoupon()`, so both now refuse expired coupons. Orders already placed keep their discount.

## How to test

**Automated**: `npm test -- coupons` → 31 passed, including the new `rejects an expired coupon`.

**Manual**
- [ ] Reproduce on `main`: apply coupon `SPRING24` (expired 1 June 2024) at checkout → 20% off applied.
- [ ] Same steps on this branch → "This coupon expired on 1 June 2024", no discount.
````

## 4. Open it

For a text-only request, the title and body go in the reply instead.

Write the body to a scratch directory beside the preview files, `git push -u origin HEAD`, then:

```bash
gh pr create --base <base> --title "<title>" --body-file <dir>/body.md --attach '<dir>/before-checkout.png#Checkout with an expired coupon, before' [--draft]
```

`--attach`, once per file, uploads it and points the body's matching `![…](./…)` at the upload; `gh pr edit` takes the same flags. Draft or ready follows the user's and the repo's habit (their instructions, the calling skill, their recent PRs), else draft. Labels, reviewers, and assignees come from the user or the template.

Read back with `gh pr view --json title,body,url`: the title as written, every preview on an uploaded asset, mermaid and diff blocks intact.

## Reply

The link and the title, then a line each for what the reviewer should know and what's left to the user, dropping empty lines:

**fix(checkout): [#42] reject expired coupons** — https://github.com/readwell-dev/shop/pull/57 (draft)
- Previews: checkout before and after, attached.
- Left to you: the two manual checks, and marking it ready.

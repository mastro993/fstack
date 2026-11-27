# Previews

Before and after captures for a change a user sees. A reviewer judges a visual change from the picture, so capture them yourself before opening the PR.

## What to capture

List the screens and states the diff changes: each page, route, component, email, or command it touches, plus the states the change reaches (empty, error, loading, a narrow viewport when layout moved). One row per changed state; three or four rows tell most stories.

- **Interaction or motion** (a flow, an animation, a drag): a short video, when the capture tool records one.
- **Terminal output** (a CLI, a generated file): a `diff` block, before lines `-`, after lines `+`.
- **A new screen** has no before, and a removed one no after: write `—` in that cell.

## Capture before and after from the same setup

1. **Run the base beside the branch.** `git worktree add <scratch>/base origin/<base>` gives the base version and keeps the user's checkout as it is. Install its dependencies the way the project does (its lockfile and package manager).
2. **Start both** with the project's own run command (README, package scripts, Makefile), on different ports.
3. **Same conditions on both sides**: the same seed or fixture data, viewport, theme, locale, and logged-in role, so every difference in the pair is the PR's.
4. **Capture** with the first tool that works: the harness's browser or preview tool; an installed headless browser CLI (`playwright-cli`, `browser-use`, `agent-browser`); or headless Chrome, `"<chrome binary>" --headless=new --window-size=1280,800 --screenshot=<file> <url>`. A mobile app goes through the harness's simulator or device tools. Ask before installing a tool.
5. **Clean up**: stop the servers you started, then `git worktree remove <scratch>/base`.

Name the files `before-<state>.png` and `after-<state>.png` and save them beside the body file, so `--attach` matches them to the body's references.

Done when every state on your list has a before and an after taken under the same conditions.

## Check every capture before it leaves the machine

Open each file and look. Attaching it publishes it, so it shows fixture data only: check for secrets or tokens, real names, emails, or customer data, internal hostnames and URLs, and other apps' notifications. Recapture with fixture data or crop it. Attach only captures you've made safe, and say in the reply which one you held back and why.

## When capture is blocked

The app needs credentials or services you lack, the build fails, or every capture tool fails: tell the user what blocked it, and ask whether they'll send the media or want the PR opened without previews. When they choose to open it, the Previews section says what's missing and why.

## Layout

| State | Before | After |
| --- | --- | --- |
| Expired coupon | ![Checkout with an expired coupon, before](./before-expired.png) | ![Checkout with an expired coupon, after](./after-expired.png) |
| Mobile, 375 px | ![Checkout on mobile, before](./before-mobile.png) | ![Checkout on mobile, after](./after-mobile.png) |

Drop the State column when there's one row. Alt text says what the image shows, for readers who can't see it. Videos go below the table, each on its own line under a bold **Before** or **After** label, since GitHub plays a video only on a line of its own.

# Previews

## What to capture

One row per screen and state the diff changes: each page, route, component, email, or command, plus the states it reaches (empty, error, loading, a narrow viewport when layout moved). Three or four rows tell most stories.

- **Interaction or motion**: a short video, when the tool records one.
- **Terminal output**: a `diff` block, before `-`, after `+`.
- **New or removed screen**: `—` in the missing cell.

## Capture

1. **Base beside branch**: `git worktree add <scratch>/base origin/<base>`, with dependencies installed the project's way.
2. **Start both** with the project's run command, on different ports.
3. **Same conditions** on both sides (seed data, viewport, theme, locale, role), so every difference is the PR's.
4. **Tool**, first that works: the harness's browser or preview tool; `playwright-cli`, `browser-use`, `agent-browser`; headless Chrome, `"<chrome>" --headless=new --window-size=1280,800 --screenshot=<file> <url>` (it won't go narrower than about 500 px; use a browser CLI for phone widths). Mobile apps: the harness's simulator or device tools. Ask before installing a tool.
5. **Clean up**: stop the servers, `git worktree remove <scratch>/base`.

Name files `before-<state>.png` and `after-<state>.png`, beside the body file.

## Check before attaching

Attaching publishes. Open each capture and confirm it shows fixture data only: no secrets or tokens, real names, emails, customer data, internal hostnames, or other apps' notifications. Recapture or crop; hold back what you can't make safe and say so in the reply.

## Blocked

Missing credentials or services, a failing build, or no working tool: tell the user what blocked it and ask whether they'll send media or want the PR without previews. Without them, the Previews section says what's missing and why.

## Layout

| State | Before | After |
| --- | --- | --- |
| Expired coupon | ![Checkout with an expired coupon, before](./before-expired.png) | ![Checkout with an expired coupon, after](./after-expired.png) |
| Mobile, 375 px | ![Checkout on mobile, before](./before-mobile.png) | ![Checkout on mobile, after](./after-mobile.png) |

Drop the State column for one row. Alt text describes the image. Videos go below the table, each on its own line under **Before** or **After**, since GitHub plays a video only on a line of its own.

<div align="center">

<img src=".claude-plugin/logo.png" alt="fstack logo: an f-shaped stack of pancakes with butter and syrup" width="200" />

# fstack

**A short stack of Claude Code skills for everyday software engineering work.**

[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat-square)](https://www.fedemas.dev/fstack)
[![Version](https://img.shields.io/badge/version-0.1.1-B4A7E5?style=flat-square)](.claude-plugin/plugin.json)
[![License: MIT](https://img.shields.io/badge/license-MIT-93D3BB?style=flat-square)](LICENSE)

</div>

---

## 🥞 Install

```
/plugin install fstack --marketplace mastro993/fstack
```

<details>
<summary>On Claude Code older than 2.1.275</summary>

```
/plugin marketplace add mastro993/fstack
/plugin install fstack@fedemas
```

</details>

## 🧈 Skills

| Skill | What it does |
| --- | --- |
| [**pr-babysit**](skills/pr-babysit/SKILL.md) | Watches a pull request through CI and review. Claude fixes failing checks, addresses or answers review comments (bots included), pushes, re-requests review, and tells you when the PR is ready to merge. |
| [**ux-stress-test**](skills/ux-stress-test/SKILL.md) | Five first-time-user personas try to reach first success in your web app in a real browser. Claude ranks the friction they hit, fixes what you choose, and reruns the personas blind to prove the fixes, or opens issues for later. |

### pr-babysit

Claude waits on GitHub without burning turns and reacts as things happen:

- 🔴 **Failing check**: reads the failed log once, fixes the root cause, reruns infra flakes once, and stops after two failed attempts.
- 💬 **Review comment**: fixes what's clear, answers questions from the code, checks bot claims before acting on them, and asks you about design calls or pushback.
- 🔁 **After a push**: replies on each thread with the fix commit, re-requests review, and leaves resolving threads to the reviewer.
- ✅ **Ready**: reports it. It never merges unless you asked.

Ask only to be told ("let me know when CI finishes") and it reports without touching anything.

**Needs:** an authenticated [gh](https://cli.github.com) CLI, git, python3, and a checkout of the PR's branch to push fixes from.

**Try it:** ask Claude to *"babysit PR #42"* or *"watch my PR and fix whatever CI or review throws at it"*.

### ux-stress-test

The personas each break your app in their own way:

- ⏱️ **Impatient**: skims, clicks the biggest button, and quits at the first error.
- 🤨 **Skeptic**: wants to know what they're signing up for before handing over anything.
- 📱 **Mobile**: small screen, touch only, slow 3G.
- 🌍 **Non-native**: reads your copy literally.
- 🔨 **Breaker**: submits junk, double-clicks, and goes back mid-flow.

**Needs:** subagents, Chrome, [browser-use](https://github.com/browser-use/browser-use) (`uv tool install browser-use`) or playwright-cli as a fallback, and the app's source code.

**Try it:** ask Claude to *"stress-test the signup flow"* or *"run a UX stress test before launch"*.

## 📄 License

[MIT](LICENSE) © Federico Mastrini

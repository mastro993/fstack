<div align="center">

<img src=".claude-plugin/logo.png" alt="fstack logo: an f-shaped stack of pancakes with butter and syrup" width="200" />

# fstack

**A short stack of agent skills for everyday software engineering work.**

[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat-square)](https://www.fedemas.dev/fstack)
[![Version](https://img.shields.io/badge/version-0.2.1-B4A7E5?style=flat-square)](.claude-plugin/plugin.json)
[![License: MIT](https://img.shields.io/badge/license-MIT-93D3BB?style=flat-square)](LICENSE)

</div>

---

## 📑 Contents

- [Install](#-install)
  - [Claude Code](#claude-code)
  - [GitHub Copilot](#github-copilot)
  - [Codex](#codex)
  - [Pi](#pi)
  - [oh-my-pi](#oh-my-pi)
  - [Any other agent](#any-other-agent)
- [Skills](#-skills)
  - [pr-babysit](#pr-babysit)
  - [pr-ship](#pr-ship)
  - [ux-stress-test](#ux-stress-test)
- [License](#-license)

## 🥞 Install

fstack installs natively in Claude Code, GitHub Copilot, Codex, Pi, and oh-my-pi, and through the skills CLI in any other agent. Start a new session after installing so your agent loads the skills.

### Claude Code

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

### GitHub Copilot

In Copilot CLI:

```sh
copilot plugin marketplace add mastro993/fstack
copilot plugin install fstack@fedemas
```

In VS Code, turn on the `chat.plugins.enabled` setting. VS Code then loads plugins installed with Copilot CLI; without the CLI, run **Chat: Install Plugin from Source** and enter `https://github.com/mastro993/fstack`.

### Codex

```sh
codex plugin marketplace add mastro993/fstack
codex plugin add fstack@fedemas
```

### Pi

```sh
pi install git:github.com/mastro993/fstack
```

Add `-l` to install for the current project only. Pi ships without subagents, which **ux-stress-test** needs, so add a subagent package from the [Pi package gallery](https://pi.dev/packages) before you run it.

### oh-my-pi

```sh
omp plugin marketplace add mastro993/fstack
omp plugin install fstack@fedemas
```

Add `--scope project` to install for the current project only.

### Any other agent

The [skills CLI](https://github.com/vercel-labs/skills) installs the skills into Cursor, OpenCode, Gemini CLI, Windsurf, and [many more agents](https://github.com/vercel-labs/skills/blob/main/docs/agents.md):

```sh
npx skills add mastro993/fstack
```

It asks which skills and agents you want, and installs into the current project unless you add `-g`. To skip the questions, name them:

```sh
npx skills add mastro993/fstack --skill pr-babysit --agent cursor -g -y
```

## 🧈 Skills

| Skill | What it does |
| --- | --- |
| [**pr-babysit**](skills/pr-babysit/SKILL.md) | Watches a pull request through CI and review. Your agent fixes failing checks, addresses or answers review comments (bots included), pushes, re-requests review, tells you when the PR is ready to merge, and keeps watching until it lands. |
| [**pr-ship**](skills/pr-ship/SKILL.md) | Ships a change. Your agent opens the PR or marks your draft ready, babysits it with pr-babysit, keeps asking the automated reviewers for another pass until one comes back clean, and merges it. |
| [**ux-stress-test**](skills/ux-stress-test/SKILL.md) | Five first-time-user personas try to reach first success in your web app in a real browser. Your agent ranks the friction they hit, fixes what you choose, and reruns the personas blind to prove the fixes, or opens issues for later. |

### pr-babysit

Your agent waits on GitHub without burning turns and reacts as things happen:

- 🔴 **Failing check**: reads the failed log once, fixes the root cause, reruns infra flakes once, and stops after two failed attempts.
- 💬 **Review comment**: fixes what's clear, answers questions from the code, checks bot claims before acting on them, and asks you about design calls or pushback.
- 🔁 **After a push**: replies on each thread with the fix commit, re-requests review, and leaves resolving threads to the reviewer.
- 🔀 **Base moved**: when another PR lands and leaves this one conflicting or behind, merges the base in (never rebases or force-pushes), resolves the conflict, and asks you when both sides disagree.
- ✅ **Ready**: tells you, then keeps watching until the PR is merged or closed, or you say stop. It never merges unless you asked; landing it is [pr-ship](#pr-ship)'s job.

Ask only to be told ("let me know when CI finishes") and it reports without touching anything.

**Needs:** an authenticated [gh](https://cli.github.com) CLI, git, python3, and a checkout of the PR's branch to push fixes from.

**Try it:** ask your agent to *"babysit PR #42"* or *"watch my PR and fix whatever CI or review throws at it"*.

### pr-ship

Say the word and your agent takes the change all the way to the base branch:

- 🚀 **Open**: commits and pushes the change if needed, then opens the PR from your template, or marks your draft ready.
- 🍼 **Babysit**: hands failing checks, review threads, and a moving base to [pr-babysit](#pr-babysit).
- 🤖 **Review rounds**: gets each automated reviewer on the repo (CodeRabbit, Pullfrog, Claude, Copilot, Codex, Bugbot, Greptile, and more) to review the latest push, fixes what they find, and asks again until a round comes back clean. If three rounds of fixes still turn up new findings, it asks you whether to keep going.
- ✅ **Merge**: squash-merges when the repo allows it (otherwise with the method it allows), pinned to the commit that passed, and only through the repo's rules, never with `--admin`.

**Needs:** pr-babysit (install both) and everything it needs.

**Try it:** ask your agent to *"ship it"*, *"get this into main"*, or *"merge #42"*.

### ux-stress-test

The personas each break your app in their own way:

- ⏱️ **Impatient**: skims, clicks the biggest button, and quits at the first error.
- 🤨 **Skeptic**: wants to know what they're signing up for before handing over anything.
- 📱 **Mobile**: small screen, touch only, slow 3G.
- 🌍 **Non-native**: reads your copy literally.
- 🔨 **Breaker**: submits junk, double-clicks, and goes back mid-flow.

**Needs:** subagents, Chrome, [browser-use](https://github.com/browser-use/browser-use) (`uv tool install browser-use`) or playwright-cli as a fallback, and the app's source code.

**Try it:** ask your agent to *"stress-test the signup flow"* or *"run a UX stress test before launch"*.

## 📄 License

[MIT](LICENSE) © Federico Mastrini

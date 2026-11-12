<div align="center">

<img src=".claude-plugin/logo.png" alt="fstack logo: an f-shaped stack of pancakes with butter and syrup" width="200" />

# fstack

**A short stack of agent skills for everyday software engineering work.**

[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat-square)](https://www.fedemas.dev/fstack)
[![Version](https://img.shields.io/badge/version-0.6.0-B4A7E5?style=flat-square)](.claude-plugin/plugin.json)
[![License: MIT](https://img.shields.io/badge/license-MIT-93D3BB?style=flat-square)](LICENSE)

</div>

---

## 📑 Contents

- [What it is](#-what-it-is)
- [Skills](#-skills)
- [Install](#-install)
  - [Claude Code](#claude-code)
  - [GitHub Copilot](#github-copilot)
  - [Codex](#codex)
  - [Pi](#pi)
  - [oh-my-pi](#oh-my-pi)
  - [Any other agent](#any-other-agent)
- [License](#-license)

## 🥞 What it is

fstack turns everyday engineering workflows into skills your coding agent runs end to end. Ask in plain words and the agent follows the same proven steps every time, coming back to you only for the decisions that are yours to make.

## 🧈 Skills

| Area | Skills |
| --- | --- |
| Planning | [feature-design](skills/feature-design/SKILL.md) |
| UX | [ux-brainstorm](skills/ux-brainstorm/SKILL.md) · [ux-stress-test](skills/ux-stress-test/SKILL.md) · [design-system](skills/design-system/SKILL.md) |
| Code quality | [comment-sweep](skills/comment-sweep/SKILL.md) |
| Pull requests | [pr-ship](skills/pr-ship/SKILL.md) · [pr-babysit](skills/pr-babysit/SKILL.md) · [resolve-merge-conflicts](skills/resolve-merge-conflicts/SKILL.md) |

## 📦 Install

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
npx skills add mastro993/fstack --skill pr-babysit --skill resolve-merge-conflicts --agent cursor -g -y
```

## 📄 License

[MIT](LICENSE) © Federico Mastrini

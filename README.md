<div align="center">

<img src=".claude-plugin/logo.png" alt="fstack logo: an f-shaped stack of pancakes with butter and syrup" width="200" />

# fstack

**A short stack of Claude Code skills for everyday software engineering work.**

[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat-square)](https://www.fedemas.dev/fstack)
[![Version](https://img.shields.io/badge/version-1.0.0-B4A7E5?style=flat-square)](.claude-plugin/plugin.json)
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
| [**ux-stress-test**](skills/ux-stress-test/SKILL.md) | Five first-time-user personas try to reach first success in your web app in a real browser. Claude ranks the friction they hit, fixes what you choose, and reruns the personas blind to prove the fixes, or opens issues for later. |

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

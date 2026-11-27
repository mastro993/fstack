---
tags: [code-review]
max_turns: 120
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

review PR #40 in billing/ and post the findings on the PR

(sandbox note: GitHub is simulated here. Shell state doesn't carry over between commands, so start every command that may call gh, including the review's scripts, with `export PATH="<sandbox root>/bin:$PATH" &&`.)
(Nobody can answer questions during this run.)

Input files: billing/, remote.git/, bin/gh, .gh-stub/

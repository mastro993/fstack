---
tags: [code-review]
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

can you review #7 in kiosk/?

(sandbox note: GitHub is simulated here. Shell state doesn't carry over between commands, so start every command that may call gh, including the review's scripts, with `export PATH="<sandbox root>/bin:$PATH" &&`.)
(Nobody can answer questions during this run.)

Input files: kiosk/, remote.git/, bin/gh, .gh-stub/

---
tags: [receiving-code-review]
max_turns: 150
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

handle the review on #31 end to end: fix whatever holds up, push it, and answer the threads. checkout's in readwell/

(sandbox note: GitHub is simulated here; put this sandbox's gh first on PATH with `export PATH="$PWD/bin:$PATH"` from the sandbox root before any gh command. Nobody can answer questions during this run.)

Input files: readwell/, remote/, bin/gh

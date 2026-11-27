---
tags: [receiving-code-review]
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

can you go through the review comments on PR 31 and sort out what we should actually do? code-review also dropped a review-findings.json in readwell/

(sandbox note: GitHub is simulated here; put this sandbox's gh first on PATH with `export PATH="$PWD/bin:$PATH"` from the sandbox root before any gh command. Nobody can answer questions during this run.)

Input files: readwell/, remote/, bin/gh

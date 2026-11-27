---
tags: [implement]
max_turns: 80
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

switch jobs/ over from our log() helper to the stdlib logging module (a logger per module) and delete jobs/log.py. heads up: the reports and billing-v2 branches still have a pile of log() calls, so we'll have to redo this on them after they merge

(Nobody can answer questions during this run.)

Input files: jobs/

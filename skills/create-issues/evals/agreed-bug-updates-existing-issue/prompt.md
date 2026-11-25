---
tags: [create-issues]
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

ok so we got to the bottom of the overdue email thing in readwell. agreed: src/reminders.js counts days overdue as elapsed milliseconds / 86_400_000, so across a clock change a 7-day gap reads as 6 days 23 hours, floors to 6, and the weekly overdue email is skipped that week. fix is to count calendar days between the due date and today in the library's timezone (Europe/London), and add a test that crosses the March clock change. file it as one issue so a volunteer can pick it up, no need to show me a draft first.

(sandbox note: GitHub is simulated here; put this sandbox's gh first on PATH with `export PATH="$PWD/bin:$PATH"` from the sandbox root before any gh command)

Input files: readwell/, bin/gh

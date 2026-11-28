---
tags: [writing-for-agents]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

i want to hand this off to a subagent: find out which of our services still call the deprecated /v1/payments endpoint, so we can switch it off at the end of the month. the code is in services/ (about 40 services, mixed go and typescript) and the api gateway access logs for the last 30 days are in logs/gateway/. write the brief i should give it. just the brief, don't run it

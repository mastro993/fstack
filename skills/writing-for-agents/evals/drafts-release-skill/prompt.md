---
tags: [writing-for-agents]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

make a skill so agents can do our npm release. steps: bump the version in package.json and add a CHANGELOG.md entry, run `pnpm test` and `pnpm build`, commit, tag vX.Y.Z, push the commit and the tag, then `pnpm publish --access public` (a publish can't be undone, we got burned once), then post the changelog entry in the #releases channel. people ask for it like "cut a release", "ship 2.4.0", "publish the new version". save it to skills/release/SKILL.md

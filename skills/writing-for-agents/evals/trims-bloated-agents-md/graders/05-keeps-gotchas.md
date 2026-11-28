---
type: llm
focus: trace
weight: 1
---

The rewritten AGENTS.md keeps both gotchas with their exact commands: the date tests need `TZ=UTC pnpm test` (or TZ=UTC), and `pnpm db:reset` drops every table and runs only against the local database on localhost:5433.

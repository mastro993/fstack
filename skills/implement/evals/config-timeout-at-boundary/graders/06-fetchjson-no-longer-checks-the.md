---
type: llm
focus: { source: file, path: pricefeed/src/http.ts }
weight: 1
---

fetchJson no longer reads process.env or getEnv, and no longer checks `typeof url` at runtime.

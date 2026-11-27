---
type: llm
focus: trace
weight: 1
---

Business functions (fetchJson, loadPrices) receive parsed settings as typed parameters or a config object rather than each reading process.env/getEnv themselves; at least HTTP_RETRIES and REQUEST_TIMEOUT_MS are parsed together at the boundary.

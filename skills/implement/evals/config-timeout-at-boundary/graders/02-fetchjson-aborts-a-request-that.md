---
type: llm
focus: trace
weight: 1
---

fetchJson aborts a request that takes longer than the timeout (e.g. AbortSignal.timeout or an AbortController with a timer), and a test proves it with a fake fetch that does not resolve in time.

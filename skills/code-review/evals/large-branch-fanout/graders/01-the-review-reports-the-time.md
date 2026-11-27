---
type: llm
focus: trace
weight: 1
---

The review reports the time-unit mismatch: the middleware passes Date.now() milliseconds to TokenBucket, which counts seconds, so it refills far too fast and doesn't limit.

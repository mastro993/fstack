---
type: llm
focus: trace
weight: 1
---

The review reports that buckets are keyed on the raw X-Forwarded-For header (spoofable, so a client bypasses the limit), rather than clientIp().

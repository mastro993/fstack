---
type: llm
focus: trace
weight: 1
---

REQUEST_TIMEOUT_MS is read and validated in one place (a config loader or parse function), not inside fetchJson on every call; a malformed or non-positive value is refused with an error naming REQUEST_TIMEOUT_MS.

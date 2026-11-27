---
type: llm
focus: trace
weight: 1
---

A test runs sync with more than one worker (concurrency above 1) and asserts that every saved document is recorded as done, or that a restart fetches none of them again.

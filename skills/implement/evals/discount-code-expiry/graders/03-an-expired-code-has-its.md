---
type: llm
focus: trace
weight: 1
---

An expired code raises its own error type (or result variant) distinct from an unknown code, checkout turns it into a message that says the code expired, and the tests assert the error type or checkout's returned result rather than comparing exception message text.

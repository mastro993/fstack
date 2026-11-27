---
type: llm
focus: trace
weight: 1
---

The password reset test no longer patches send_email; it asserts on what the recording transport received (or an equivalent observable result), and the tests that only covered send_email itself were deleted or replaced by Mailer-level tests.

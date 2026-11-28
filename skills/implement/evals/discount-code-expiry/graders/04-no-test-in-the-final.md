---
type: llm
focus: trace
weight: 1
---

No test in the final tree patches or asserts calls to till's private internals (`_lookup`, `_CODES`, or their replacements); the tests that did were rewritten to drive apply_code or checkout through their public interface, and the old test comparing `str(exception)` to "unknown code: NOPE" now asserts the error type or checkout's result.

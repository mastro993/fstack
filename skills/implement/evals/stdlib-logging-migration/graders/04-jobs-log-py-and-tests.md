---
type: llm
focus: trace
weight: 1
---

jobs/log.py and tests/test_log.py are deleted, nothing imports or re-exports log() anymore, and the invoices test asserts the warning with assertLogs (or a log handler) instead of patching jobs.invoices.log.

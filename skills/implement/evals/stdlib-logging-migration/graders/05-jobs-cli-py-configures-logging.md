---
type: llm
focus: trace
weight: 1
---

jobs/cli.py configures logging once (for example logging.basicConfig with a level and a format) so a job run by hand still prints its messages to stderr, and no job module configures handlers itself.

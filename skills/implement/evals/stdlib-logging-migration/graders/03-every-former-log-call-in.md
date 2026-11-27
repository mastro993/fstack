---
type: llm
focus: trace
weight: 1
---

Every former log() and log.log() call in jobs/ now goes through a module-level logging.getLogger(__name__) logger at the matching level: warn became warning, fatal became critical, and retry.py still picks warning or error at runtime.

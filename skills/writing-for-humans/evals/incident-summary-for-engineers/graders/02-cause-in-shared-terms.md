---
type: llm
focus: trace
weight: 1
---

summary.md explains the cause as the WEB_CONCURRENCY increase exhausting pgbouncer client connections (960 against max_client_conn 600), using these terms without defining p99, pgbouncer, or connection pool for the reader.

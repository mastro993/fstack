checkout-api incident 2026-11-20 (all times UTC)

14:02 deploy 4f1c2a of checkout-api, WEB_CONCURRENCY 4 -> 12 per pod
14:06 p99 latency 380ms -> 4.1s, alert fired
14:09 5xx rate climbing, peak 18% at 14:21
14:15 pgbouncer shows pool saturated: 12 workers x 8 pods x pool_size 10 = 960 client conns vs max_client_conn 600
14:31 decision: roll back instead of raising max_client_conn (db max_connections headroom unclear)
14:38 rollback to 9b07e1 complete
14:44 p99 back under 400ms, 5xx at baseline
customer impact: failed checkouts count pending from analytics (ETA Monday)
follow-ups:
- add a CI check: workers x pods x pool_size <= max_client_conn
- decide on pgbouncer max_client_conn vs postgres max_connections (owner: Ines)
- load test concurrency changes before deploy

# ledger

Cron runs `python3 -m ledger.import_payments data/` every night. The bank drops one CSV per day in
`data/inbox/`; the import loads each file into `data/ledger.db`, moves it to `data/processed/`, and writes
`data/summary.json` for the finance dashboard.

Tests: `python3 -m unittest discover -s tests -t .`

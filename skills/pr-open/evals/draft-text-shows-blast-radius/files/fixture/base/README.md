# shelfwise

Circulation service for the branch libraries: loans, holds, and the nightly reports.
Scheduled jobs live in `jobs.py` and run from cron.

## Tests

```sh
python3 -m unittest discover -s tests -v
```

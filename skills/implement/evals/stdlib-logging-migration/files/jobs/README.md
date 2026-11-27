# jobs

Nightly batch jobs. The app's scheduler imports each module under `jobs/` and calls its `run()`;
`python3 -m jobs.cli cleanup <dir>` runs the cleanup by hand. Everything logs through
`jobs.log.log(level, message)`, which prints `[LEVEL] message` to stderr.

Tests: `python3 -m unittest discover -s tests -t .`

# pricefeed

Pulls supplier prices every few minutes and prints the ones that changed. Node 24 runs the TypeScript
directly; `npm test` runs the suite.

| Variable | Meaning | Default |
| --- | --- | --- |
| `FEED_URL` | supplier price endpoint | required |
| `HTTP_RETRIES` | retries after a failed request | 2 |

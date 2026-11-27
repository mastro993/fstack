# docsync

Mirrors the docs API to disk for the offline help viewer. `npm run sync` lists every document at
`DOCS_API` and saves each one to `out/<id>.md`, four downloads at a time.

A full sync takes about an hour and the box it runs on gets recycled now and then, so progress is kept
in `state/progress.json` (`{"done": ["<id>", ...]}`). A restarted sync skips every document listed there.

Tests: `npm test`

---
type: regex
target: { source: file, path: .gh-stub/issues.json }
pattern: '!\[[^\]]*\]\((?!https://)[^)]*\)'
match: not_contains
weight: 1
---

No issue body embeds an image by a local path; every image points at an uploaded or pushed URL.

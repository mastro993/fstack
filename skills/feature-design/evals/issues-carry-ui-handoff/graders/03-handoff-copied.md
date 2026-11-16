---
type: regex
target: { source: file, path: .gh-stub/issues.json }
pattern: '^(?=[\s\S]*This link was already used)(?=[\s\S]*--rw-accent)(?=[\s\S]*btn secondary)'
flags: i
weight: 1
---

The confirm page's handoff was copied into the issues, not summarized: its copy ("This link was already used"), its tokens (`--rw-accent`), and its component map (`btn secondary`).

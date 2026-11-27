---
type: regex
target: { source: file, path: readwell/.git/HEAD }
pattern: 'ref: refs/heads/.*RW-14'
weight: 1
---

The run ends with a branch whose name contains the key RW-14 checked out.

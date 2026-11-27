---
type: llm
focus: { source: file, path: shopkeep/src/orders.ts }
weight: 1
---

Order state lives in a single status field (a union, enum, or state machine) covering pending/unpaid, paid, shipped, and cancelled; the file has no isCancelled (or similar third) boolean beside isPaid/isShipped, and isPaid/isShipped are no longer independent stored booleans.

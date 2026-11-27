---
type: llm
focus: trace
weight: 1
---

The blast radius says that the front desk's hand_over_hold (circulation/desk.py) now fails for a hold that is still `requested`, because collect requires `ready`.

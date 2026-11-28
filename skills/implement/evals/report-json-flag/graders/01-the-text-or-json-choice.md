---
type: llm
focus: trace
weight: 1
---

The text-or-JSON choice is made in one place, where the CLI handles its arguments, and lower layers receive a ready value (a render function, a formatter object, or the summary to render) instead of a json/format flag they check again.

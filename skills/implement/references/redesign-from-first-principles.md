# Redesign from first principles

Fit a new requirement into the design as if it had been a founding assumption, instead of bolting it onto the design as it stands.

- Read every file the change touches and its callers until you can say how the current design works and why it has that shape.
- Ask: written from scratch with this requirement, what would we build? That answer is the end state. It decides the types, where each rule lives, and what the old design no longer needs.
- Think through the whole redesign, then deliver it in small steps that each move toward it.
- Propagate the change through every reference: types, call sites, docs, README tables, examples, and comments that give the rationale.

**Test:** a reader of the final code can't tell which requirement came last. A bolt-on shows as a flag or branch beside the old design, a parameter only the new caller passes, a wrapper around the old function, or docs that still describe the old shape.

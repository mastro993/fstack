# Laziness protocol

Make the smallest change that fully solves the problem, and make each decision once.

- **One source of truth per decision.** When a choice (a mode, an output format, an environment, a feature switch) affects several places, make it once, where the input arrives, and pass the result in as a plain value: a function, an enum, a config object. The places that use it act on that value instead of asking the question again.
- **Smallest diff.** Fewer lines beat elegant boilerplate. An edit in one place beats a new layer with one implementation.
- Measure "smallest" against the end state, not the old design: a redesign that deletes more than it adds is a small diff.

**Test:** search for the decision (the flag name, the mode string): it is read in one place. Each added line is needed for the requirement or removes more than it costs.

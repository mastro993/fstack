# Build the lever

Non-trivial work gets a tool that does it or proves it: a codemod or script for repeated edits, a script for a data fix or an analysis, a generator for repeated code, a rerunnable check for a claim no test makes (every caller moved, every row fixed). The tool is what a reviewer can rerun. A behavior change's failing-first test already proves it.

- The bar is triviality, not repetition: only a couple of obvious edits go without a tool.
- Do the first unit by hand, then build the smallest tool that does or proves the job, never a framework. Prove it by rerunning it on that unit, and make it safe to rerun: a second run changes nothing.
- A deterministic tool beats fanning out to subagents. To fan out, write the recipe, the verification contract, and the fences as one skill the delegates read and cannot edit.
- Keep the tool in the diff when the work outlives the session (other branches, future data, a recurring check), with a line on how to run it; otherwise delete it once it has run.

**Test:** the report's Levers line names each tool, what it did or proved, and whether it stayed.

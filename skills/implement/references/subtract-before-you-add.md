# Subtract before you add

Remove complexity first, then build on the simpler base. Leave the design a little simpler and more capable, behind the same or a smaller surface.

- Remove before you build: delete what nothing uses, build the change, then delete what the new code replaced.
- List what the end state no longer needs in the change's path, and delete it as part of the change: dead code, unreachable branches, checks the types now guarantee, pass-through layers, the API being replaced, tests that only covered deleted code, and docs that describe something gone. Dead code elsewhere goes in Follow-ups.
- Build for the usage you can see. Add a helper, layer, option, flag, guard, parser, or dependency only for duplication, branches, or inputs that exist now; guards and fallbacks live at boundaries.
- Cut before you polish: reach the smallest version that works, then improve it.
- When a doc section, comment, or reference has nothing left to say, delete it rather than leave a stub.

**Test:** every line the diff adds serves the requirement, and the Removed line of the report lists what the end state no longer needed.

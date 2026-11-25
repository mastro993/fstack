# Handoff

Follow this once the user has confirmed the system and picked a delivery. For **Both**, do Plan, then Issues. Every pick ends with [Building in a new session](#building-in-a-new-session). Where the project already keeps plans or specs, its location and format win over the ones here.

## First, for every pick: commit the spec

Commit `DESIGN.md` and every approved spec change, on a branch unless the user says otherwise. Everything after this reads from the repository, not from this conversation.

## Plan

1. Write the plan to `docs/design-system/plan.md`, or to the project's own plans or specs folder, in the plan format of [formats.md](formats.md#plan-docsdesign-systemplanmd).
2. Update every page under `docs/` whose description the plan makes wrong, and link the plan from the project's docs index when it has one.
3. Commit the plan with the spec.

Done when the plan holds the catalog with a tier for every component, every opportunity with its call sites, and the slices in order with their checks and dependencies.

## Issues

Load the create-issues skill and follow it. The contract is `DESIGN.md` and the plan, or the confirmed system when the user picked Issues alone; its slices are a proposed split, in build order (tokens, then atoms, molecules, organisms). Each issue also carries the components and call sites of [formats.md](formats.md#issue). Done when that skill hands back.

## Building in a new session

Ask whether to start building now. On yes, start a new session with the harness's own means (a new thread, session, or background agent); without one, give the user a prompt to paste. A new session sees only what is on disk in its checkout, so start it in this checkout or in one that has the commit.

The prompt names the plan or the issues, `DESIGN.md`, and the first slice, and says:

- build the slices in order, one at a time, each with its tests, and keep the app working after each;
- write the module README from the plan's outline in the first slice, and add each component to its catalog as it lands;
- ask before adding any dependency, or before changing a spec file beyond what the plan approved.

Done when the new session is running, or the user holds the prompt, or they said not now.

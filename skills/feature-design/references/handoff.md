# Handoff

Follow this once the user has picked how to continue. For **Both**, do Issues, then New session.

## First, for every pick: commit the docs

Both handoffs read the docs from outside this conversation. Commit the spec, ADRs, glossary, and updated docs, on a branch unless the user says otherwise.

## Issues

Load the create-issues skill and follow it. The contract is the spec, with its ADRs, glossary, and prototypes; its slices are a proposed split, and its numbered decisions and acceptance checks are the requirements. Done when that skill hands back.

## New session

Start a new session with the harness's own means (a new thread, session, or background agent). Without one, give the user a prompt to paste. The prompt names the spec, the ADRs, and the first slice or issue, and says to implement from them as decided, test-first with the test-driven-development skill, turning each acceptance check into a test.

A new session sees only what is on disk in its checkout: start it in this checkout, or in one that has the commit.

Done when the new session is running, or the user holds the prompt.

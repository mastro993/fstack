# Handoff

Follow this once the user has picked how to continue. For **Both**, do Issues, then New session.

## First, for every pick: commit the docs

Both handoffs read the docs from outside this conversation. Commit the spec, ADRs, glossary, and updated docs, on a branch unless the user says otherwise.

## Issues

Issues outlive branches: a link to the docs branch dies once it merges and is deleted, and a link to the default branch drifts as the docs change. So the docs land on the default branch first, and each issue links them at a fixed commit there, which shows them exactly as they were when the issue was written.

1. **Find the tracker** from the project: the git remote with `gh`, or a tracker MCP. With none reachable, say so, leave the slices in the spec, and stop here.
2. **Land the docs.** Skip to step 3 when the spec, ADRs, and doc updates are already on the remote's default branch. Otherwise push the docs branch and open a pull request for it the way the user and the repo open theirs (draft or ready for review, the PR template), and say in its body that the issues follow its merge. Tell the user in a line, with the link, that the issues wait for the merge, and, for a draft, that it waits on them to mark it ready. Then load the pr-babysit skill and run it on that PR; merge it only if the user asked. When it reports the PR merged, continue here. If the PR closes unmerged, or the push fails, ask the user how to go on.
3. **Read the docs as merged**: update the local default branch and build the issues from it, since review may have changed the spec. Link every file at the default branch's head commit, by its full SHA (`git rev-parse origin/<default-branch>`): `https://github.com/<owner>/<repo>/blob/<sha>/<path>`, or the tracker's equivalent.
4. **Create one issue per slice** of the spec, in dependency order, so each issue can name its blockers by number. Each issue has an outcome as its title, what to build, acceptance checks, links to the spec and its ADRs, and what it is blocked by, in the issue format of [formats.md](formats.md). Use the tracker's own dependency or sub-issue links when it has them, and label the issues the way the project labels its own. Where an issue for a slice already exists, update it to these links instead of opening another.
5. **Reply** with the issue links and the implementation order: what comes first, what can run in parallel, and why.

Done when the docs are on the default branch, every slice has an issue whose links name a commit on it, every blocker is named by number, and the user has the order.

## New session

Start a new session with the harness's own means (a new thread, session, or background agent). Without one, give the user a prompt to paste. The prompt names the spec, the ADRs, and the first slice or issue, and says to implement from them as decided, test-first with the test-driven-development skill, turning each acceptance check into a test.

A new session sees only what is on disk in its checkout: start it in this checkout, or in one that has the commit.

Done when the new session is running, or the user holds the prompt.

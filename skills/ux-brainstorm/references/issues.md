# UI in issues

Follow this for every issue that builds an area settled by ux-brainstorm, whichever skill files it. The session that picks the issue up has no prototype, no `OUT`, and none of this conversation, so the issue is its whole picture of the agreed design: what the issue leaves out, that session invents.

## What the issue carries

A `## UI` section with, for each area the issue builds:

- **Screenshots**, embedded: the approved variant at its first state, then each state that changes the layout.
- **The handoff**, copied from the spec or decision record, not summarized: the approved variant in words, states, component map, tokens, copy, and interactions. When an area spans several issues, copy the rows for the elements this issue builds.
- **A link** to the spec section or decision record it came from.

Add an acceptance check: "Matches the screenshots in light theme, and in dark through the mapped tokens; any change to the agreed design is approved by the user first."

## Attaching the screenshots

When `gh issue create --help` lists `--attach`, write the body to a file in the screenshots' folder, reference each screenshot there as `![Library, Empty](./library-empty.png)`, and from that folder run `gh issue create --body-file <file>` with one `--attach './library-empty.png#Library, Empty'` per screenshot. gh uploads each image and rewrites its reference to the uploaded copy.

With another tracker, use its own upload. With no upload at all, commit the screenshots beside the spec, push, and embed each by its URL at that commit: `https://github.com/<owner>/<repo>/blob/<sha>/<path>?raw=true`.

Done when every such issue, read back from the tracker (`gh issue view <n> --json body`), shows each screenshot as an uploaded or pushed URL, never a local path.

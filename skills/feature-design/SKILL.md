---
name: feature-design
description: Use when the user has a rough idea for a feature, product change, or new capability and wants to brainstorm, shape, design, or spec it before building, such as "I'm thinking of adding…", "how should we approach…", "help me design…", or "write a spec for…".
compatibility: Works best with a question tool (AskUserQuestion or the harness's equivalent), the Exa MCP for research, a harness that renders HTML or diagrams inline, and an issue tracker CLI or MCP for the handoff.
---

# Feature design

You are the tech lead shaping this feature with its owner. They bring a rough idea and own what it is for: the problem, who it serves, scope, behavior, and UX. You own how it is built. Turn the idea into a spec someone can implement without reopening the conversation, and spend little of the user's attention getting there.

- **Brief**: the idea framed in a few lines: the problem, who has it, the outcome that counts as success, and what is out of scope.
- **Product decision**: a choice about scope, behavior, UX, or user impact. The user makes the ones that matter most; you make the rest and record them as assumptions.
- **Technical decision**: a choice about how it is built (data, architecture, libraries, protocols). Always yours; the user hears about it in step 4.
- **Round**: one use of the question tool, with up to five questions. The whole interview gets three rounds.
- **Glossary**: the project's agreed words for its concepts, in `GLOSSARY.md` at the repository root. The interview sharpens it.
- **ADR**: a short record of one decision and why, in `docs/adr/`.
- **Spec**: the full feature specification, in `docs/specs/<slug>.md`.

File formats are in [references/formats.md](references/formats.md). Where the project already keeps a glossary, ADRs, or specs, its location and format win.

Search the web with the Exa MCP whenever a step needs research (when its tools aren't listed yet, look them up with ToolSearch before calling them missing). Fall back to the harness's own web search only when Exa is missing, unauthenticated, or erroring, and say in the reply that you did.

## 1. Ground the idea

The user is not the source of truth; the project and the world are. Before framing anything:

- **Read what was already decided**: everything under `docs/` that touches the idea, every ADR (they are short, and one you skipped is the one you will contradict), the glossary, and the README. Past design sessions left their decisions there.
- **Read the code** the idea touches: what exists today, what already half-solves the problem, the data and rules behind it, and the stack's constraints.
- **Check the tracker** for issues that already ask for this, or decided against it.
- **Research outside**: how established products solve the same problem, and what the libraries or platforms involved can and can't do. Search with Exa, and trust what you find over what you remember.

With subagents, run these in parallel. Done when you can say what the real problem is, what the project already has, and where the idea as stated is wrong, wasteful, or in conflict with a past decision.

## 2. Frame and challenge

Write the brief. Then tell the user what you found, before any question, in plain words and with the evidence (the ADR, the file, the source):

- what's wrong with the idea as stated: it already exists, it contradicts a recorded decision, it treats a symptom, a much smaller change reaches the same outcome, or the research shows it fails in a known way;
- the shape you would give it instead, and why that serves their goal better.

Don't soften this into a question, and don't drop it because the user sounded sure. They can overrule you in the round that follows, where reshaping versus keeping the idea is the first question.

Then list every open decision and sort it:

- **Technical** → yours. Never ask it.
- **Product, answerable from the grounding** (code, docs, ADRs, common practice) → decide it, and record it as an assumption.
- **Product, and only the user can know** → rank by how much of the spec changes with the answer and how costly a wrong guess is to undo. The top of this list is the interview; with fifteen questions at most, the tail becomes assumptions too.

Done when the user has read the challenge and you hold a ranked list of questions.

## 3. Interview

Up to three rounds of up to five questions. The budget is the point: the user's attention is the scarce resource, so each question has to earn its place, and an interview that never ends ships nothing. Stop early when no remaining answer would change the spec.

Ask every question through the question tool (AskUserQuestion, or whatever the harness offers), never as free-form text in the reply: options make the user pick instead of write, and keep answers comparable. Without any question tool, ask the round as numbered questions with lettered options the user can answer in one line ("1B 2A 3C").

Go from wide to narrow: the first round settles the problem and the shape of the solution, the next ones behavior, UX, and edge cases. Later rounds build on earlier answers, so don't write them in advance.

Each question:

- is about the feature, its users, or its UX, never about how to build it;
- names what the user or their users will notice, in the user's own words, without internal terms;
- offers two to four concrete options, each described by what people will see, gain, or lose. For a choice, your recommended option comes first, labeled (Recommended); for a fact only the user knows (why it happens, how often), offer the likely answers and "I don't know", and say what you will assume then;
- says so when an option changes how the product behaves today, or goes against a recorded decision.

**Make sure the question is understood.** A choice the user can't picture gets a guess for an answer. Before the round, or inside the options, show what the options mean:

- an example with realistic data ("Ana offers her Friday shift; Ben sees…");
- a diagram for flows, states, or how parts relate (Mermaid when the harness renders it, otherwise ASCII);
- side-by-side mockups in the question tool's option previews, when it has them;
- a small interactive HTML prototype when the choice is about feel or a multi-step flow, rendered inline when the harness can and opened in the browser otherwise. When the whole question is what a screen should look like and the ux-brainstorm skill is installed, hand that part to it.

Use the lightest aid that makes the options clear; one-line examples are often enough.

**Build the glossary as you go.** Shared words are half of a shared understanding:

- When the user's word conflicts with the glossary or the code ("trade" where the project says "swap"), say so and use the project's term.
- When a word is vague or covers two concepts ("account": the customer or the login?), make telling them apart one of the round's questions, or settle it yourself when the grounding answers it.
- Test fuzzy boundaries with a concrete scenario instead of a definition.
- Write each term into the glossary as soon as it is settled, not at the end.

After each round, record the answers as numbered decisions. When the budget runs out with items still open, decide them yourself with the option you would have recommended, and list them as assumptions. Done when every question on the list has a decision or an assumption.

## 4. Design it and explain it

Now make the technical decisions: architecture, data, interfaces, libraries, rollout. Let the decisions from the interview and the project's constraints (existing architecture, ADRs, stack, scale) shape them, research anything you plan to depend on (again with Exa), and prefer the smallest design that makes the agreed behavior hold.

Then restate the shared understanding and explain the design to the user, once, in one message:

- **What we agreed**: the brief and the numbered decisions, with your assumptions marked as such.
- **How it will be built**: each technical decision as what and why, tied to a need they stated ("Swaps must work with no signal on the shop floor, so the app saves them on the phone first and sends them when it's back online"). Plain English, no jargon; when a technical word is unavoidable, explain it in half a sentence. Add a diagram when the parts and their order matter.
- **What it costs them**: limits, risks, and what gets harder later.

This is the first time the user hears the technical side. Before a shared understanding exists it is noise; after, it is how they check that you understood them.

## 5. Document

Write everything down before the handoff, so the next session, and the next feature design, starts from files instead of from this conversation:

- **ADRs**: one per non-trivial decision, product or technical: there was a real alternative, and a future reader would otherwise wonder why. Include the alternative the user rejected. When a decision replaces an earlier ADR, mark the old one superseded and link both ways; never leave two ADRs that disagree.
- **Glossary**: every term settled during the interview.
- **Existing docs**: update any page under `docs/` whose description the feature will make wrong.
- **Spec**: `docs/specs/<slug>.md`, per the format file. It links the ADRs instead of repeating their reasoning, and ends with the implementation slices in order.

Done when someone with only the repository could build the feature, and would learn from it why each choice was made.

## 6. Hand off

Reply with the paths and a three-line summary, then ask, with the question tool, how to continue:

1. **Open issues** on the project's tracker.
2. **Implement now**, in a new session with a fresh context.
3. **Both**: issues first, then the new session.

Any correction the user gives instead goes into the decisions, the ADRs, and the spec before you ask again. Don't implement in this session: its context is full of exploration and rejected options, and the spec exists so the work can start clean.

**Issues.** Find the tracker from the project (the git remote and `gh`, or a tracker MCP); with none reachable, say so and leave the slices in the spec. One issue per slice of the spec: a thin end-to-end piece that can ship and be verified by itself, never a layer ("the database part"). Each carries what to build, acceptance checks, links to the spec and its ADRs, and what it is blocked by. Create them in dependency order so each can name its blockers by number, use the tracker's own dependency or sub-issue links when it has them, and label them as the project labels its issues. Then give the user the links and the implementation order: what comes first, what can run in parallel, and why.

**New session.** Start it with the harness's own means (a new thread, session, or background agent), or, without one, give the user a prompt to paste. The prompt names the spec, the ADRs, and the first slice or issue, and says to implement from them without re-deciding anything. A new session sees only what is on disk in its checkout: start it in this one, or commit the docs first, on a branch unless the user says otherwise.

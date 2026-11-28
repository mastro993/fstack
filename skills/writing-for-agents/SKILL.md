---
name: writing-for-agents
description: Use when writing, editing, or reviewing text an AI agent will read and act on, such as a SKILL.md, an AGENTS.md or CLAUDE.md, a system prompt, a subagent brief, or a tool description, or when the user asks why an agent ignores its instructions or wants one of those files trimmed or tightened.
---

# Writing for agents

Your reader is a capable model. It already knows most of what you could tell it, it reads every line, and it tries to obey each one. So every line costs twice: the tokens to read it and the effort to follow it. Instructions an agent didn't need still make it reason longer and do worse.

## 1. Keep only lines that change behavior

Test each line: would the agent get this wrong without it? Keep the line only when the answer is yes. Lines that pass:

- facts it can't find on its own: conventions, environment quirks, decisions and the reasons behind them, places where the project departs from the usual default;
- exact commands, names, and limits for fragile steps;
- what done looks like, and when to stop.

Cut the rest:

- What the agent can discover: directory tours, file lists, what the code already says. Point to `src/billing/charge.ts:42` instead of copying code; copies go stale.
- Advice it already follows ("handle errors appropriately", "follow best practices"). Write the specific pattern, edge case, or convention it stood in for, or delete it.
- Anything tied to a date or a passing phase ("until the migration ends"). State the rule as it stands now; move retired guidance into an "Old patterns" section only if agents still meet the old code.

Facts that contradict a reasonable assumption ("tests need `TZ=UTC`", "the staging DB is shared with QA") are usually the most valuable lines in the file. Collect them under a Gotchas heading, and add one each time you correct an agent.

## 2. Phrase each rule

- **Say what to do.** "Write flowing prose paragraphs" works better than "don't use markdown": a prohibition names the thing to avoid and leaves the agent guessing at the alternative. Keep a negative only for a safety rule with no positive form.
- **Give the reason for any rule that isn't obvious.** The agent generalizes from the reason. "No ellipses" covers one case; "no ellipses, because a text-to-speech engine reads this aloud" also covers the cases you didn't list.
- **Write in a calm voice.** Capitals and "CRITICAL: you MUST" make current models apply the rule everywhere, including where it doesn't fit. Write "Use X when Y", and replace blanket fallbacks ("if in doubt, use X") with the real condition.
- **Match strictness to the cost of a mistake.** A fragile or irreversible step gets the exact command, to run as written. A step with many good answers gets the goal and a heuristic. Set the level for each part separately: rigid if-else trees break on the first unlisted case, and vague guidance guides nothing.
- **One term per concept, one default per choice.** Pick "field" and keep it; a switch to "box" reads as a different thing. Name one recommended tool and one fallback for when it fails, rather than a menu.
- **One source of truth.** Rules that contradict each other make the agent spend its reasoning reconciling them, and it may pick the wrong one. Merge duplicates, and when two rules can collide, say which wins.
- **Exact names.** Fully qualified tool names (`server:tool`), forward-slash paths, and the dependencies the text assumes are installed.

## 3. Shape the document

- Put background, instructions, examples, and inputs under separate headings or XML tags, so the agent can tell a rule from data.
- Teach a pattern with 3 to 5 short, varied examples rather than a long list of edge-case rules, each in an `<example>` tag.
- For an output format, give a template and say whether it is strict or a starting point.
- Keep the main file short (a SKILL.md well under 500 lines) and move detail into files linked straight from it, one level deep, each with its trigger: "read `references/api-errors.md` when the API returns a non-200 status". Agents often read only the top of a long file, so a reference over 100 lines opens with a table of contents.
- Put long input documents first and the task or question last.

## 4. Per kind of text

- **Skill description**: the agent picks among many skills from this text alone. It says when to use the skill: the situations and the words users actually type, with specific key terms. How the skill works belongs in the body. Stay under 1,024 characters, and single-quote the value when it contains ` #`, which YAML reads as the start of a comment.
- **Subagent brief**: the subagent knows only what the brief says. Give the goal and why it matters, what is already ruled out, the sources and tools to use, the scope it must stay inside, the return format, and how much effort the task deserves (a lookup takes a few tool calls). Vague briefs produce duplicated work and gaps.
- **AGENTS.md or CLAUDE.md**: write it by hand; generated ones lowered task success and raised cost. Name the commands and tools you want used, since agents reach for whatever the file mentions, and mention only those.
- **Tool description**: write it for a new hire: what the tool does, when to pick it over its siblings, unambiguous parameter names (`user_id`, not `user`), and a shared prefix for related tools. Error messages say what to fix and show a valid input.
- **Anything that lets an agent act**: say when to stop and hand back, which actions run freely (local and reversible), and which wait for confirmation (destructive, or touching shared systems).

## 5. Check before you hand it over

1. Read it as the agent would: two rules that conflict, a step without a done condition, a term used two ways.
2. Search it for capitals used for emphasis, "never" and "don't" rules, generic advice, rules said twice, and dates. Rewrite each as in step 2.
3. Ask of every remaining line whether the agent would get the task wrong without it, and cut each line that fails.

For a skill or prompt that will run often, test it as well. Run the task without it first to see what the agent actually gets wrong, write about three scenarios, and write the least text that fixes them. Then read the agent's step-by-step transcript, not only its final output, to find lines it ignored or over-applied. For a skill description, try about 20 requests, half of them near-misses that should not trigger it.

When you rewrite someone else's text, keep the meaning of every rule you keep. End your reply with a short list of what you cut and why, and of anything you added or loosened, so they can restore a line that mattered or reject one they never asked for.

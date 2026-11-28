---
name: writing-for-humans
description: 'Use when writing or editing prose that people will read, such as docs, READMEs, guides, reports, emails, announcements, release notes, or issue and PR text, or when the user asks to make text clearer, plainer, shorter, or less AI-sounding ("this reads like a bot wrote it", "humanize this", "make it sound like a person").'
---

# Writing for humans

Write text a person can read once and act on. Work in two passes: draft for substance, then check the draft in a separate pass. A check pass catches more than rules held in mind while drafting.

## Draft: get the substance right

Wordy habits are symptoms. Text with no clear point, no specific claim, or no source stays bad after its words are cleaned, so fix what the text says first.

- **Know the reader**: who reads it, what they already know, what they do next. Define a term they may not know the first time it appears ("Arabidopsis, a flowering mustard plant") and spell out each abbreviation once. Keep the terms they share: engineers reading about p99 latency need no definition of p99.
- **Lead with the answer.** The first one or two sentences carry the bottom line ("The refund arrives in 3 working days."); the rest follows in order of importance.
- **Make every claim specific and true.** Name the source ("the 2025 support survey found…") or drop the claim. Every name, date, number, and citation in the final text is real. When a fact is missing, ask the user. When nobody can answer, write the text so it can go out as is, leaving out or writing around the missing fact, and name the gap in your reply: a vague true sentence beats a specific invented one or a placeholder.
- **Give every sentence new information.** Open with the point and stop when the information ends. Preamble ("Let's break this down"), narration of your own process, closers that restate the answer, lines that only sound wise, "In conclusion", and chat openers and sign-offs ("Great question!", "I hope this helps", "Let me know if…") all go.

## Draft: write plainly

- Say what a thing is. Use "not X but Y" only to correct a belief the reader actually holds.
- Use "is", "are", and "has" where a draft reaches for "serves as", "stands as", or "boasts".
- Give the fact that earned the praise in place of the praise ("groundbreaking", "vibrant", "pivotal role"), and end the sentence at the fact rather than on an "-ing" tail about its significance ("…, highlighting its importance").
- Name as many items as exist. A list of three is right when there are three.
- Call one thing by one name throughout: "the app" each time, not app, platform, and solution in turn.
- State a problem with its status ("Exports above 10,000 rows still time out; the fix ships in March") in place of a challenges paragraph that ends in optimism.
- Address the reader as "you", in the active voice: "Submit the form." Give steps plainly, without "simply", "just", or "it's easy".
- Keep sentences under about 25 words and paragraphs to one idea, and vary sentence length so the rhythm stays uneven.
- Keep a voice. Greetings, transitions, a formal tone, and correct grammar are normal human writing; keep them where the genre expects them, since clean but voiceless prose reads as machine-made too. When the user shares a sample of their writing, match its habits.

## Draft: format for where it lands

A format the repo, a template, or the calling skill sets for this text wins; these rules fill in the rest.

- Headings in sentence case. Bold only the rare phrase the reader must not miss, and keep bullets plain. Leave emoji out unless the user's own writing uses them.
- Prose for a line of reasoning, lists for items the reader scans, and a table when several items share several attributes. Two facts make a sentence.
- At most one em dash per paragraph; commas, colons, and parentheses do the rest.
- Markdown only where it renders. Email, chat apps, and plain-text fields get plain text, with no `##`, `**`, or tool tokens.

## Check pass

1. Reread as the reader, sentence by sentence, as if aloud. Rewrite any sentence that is awkward spoken, and any paragraph the reader couldn't restate in their own words.
2. Hold the draft against each rule above.
3. Read [references/patterns.md](references/patterns.md) and scan the draft for its patterns, then its words. One listed word alone is fine; several together mark autopilot prose. Fix a hit by rewriting the sentence around a specific fact. Swapping in a synonym only trades one tell for the next.

The word list is English. For another language, apply the same patterns and watch for that language's own stock phrases and literal calques from English.

## Editing someone else's text

Keep their meaning, facts, and voice, and change what a rule flags. Return the revised text, then list in a line or two any claim you couldn't make specific without facts from them, such as a quote credited to "experts" with no name.

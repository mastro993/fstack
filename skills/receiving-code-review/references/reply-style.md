# Replies

A reply says what changed or why not, specifically. The action is the acknowledgment, so a reply carries no thanks, praise, or agreement for its own sake, no apology, and no hedging: state it, or ask it.

Never write "Thanks", "Great catch", "Good point", "You're absolutely right", "Agreed", "Sorry", "I think", "maybe", "perhaps", "Will fix", or "Let me…". `validate_plan.sh` rejects the common ones.

## By verdict

**accept**, posted only once the fix is on the PR head: `Fixed in {sha}: <what changed>.` Name the function or behavior, and the test that covers it when there is one. `post_replies.sh` fills in `{sha}`.

> Fixed in {sha}: `parseQuantity` now rejects negative quantities; "rejects a negative quantity" in test/cart.test.ts covers it.

**reject**: the reason and its evidence in one to three sentences: the file:line, the test, the probe's output, or the decision record.

> `slugify` already lowercases its input (`src/text.ts:18`), so "Hello World" and "hello world" get the same slug; a probe printed `hello-world` for both.

> ADR 0007 (docs/adr/0007-money-in-cents.md) keeps prices as integer cents to avoid rounding drift; floats would undo that. Changing it needs a new ADR, outside this PR.

**clarify**: one question whose answer picks the fix, with the readings named.

> Should the retry limit count per request or per user session? The first changes `fetchWithRetry`, the second the session store.

**needs-human**: no reply. Anything you post would pre-empt a decision that isn't yours; the report carries it to the user.

## Shape

- A thread reply doesn't quote the comment: it sits right below it.
- A reply to a review body or conversation comment goes out as a PR comment that links the source. When that source made several points, start with the one you're answering.
- Same tone for bots and humans.
- Backticks for code, file:line for places, one to three sentences.

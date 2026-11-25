# Worked examples

One per tier, plus a bug, all from one grocery-ordering app. Each shows the contract, the tier decision, the triggers that fired, and the issues.

## XS: delivery fee on the receipt

**Contract**: R1 the order receipt shows the delivery fee as its own line; R2 a free delivery shows "Free".
**Tier**: XS. About 40 lines in the receipt template and its formatter, one module, nothing open.
**Triggers**: none, so one issue.
**Issues**: 1. "Receipts show the delivery fee" (minimal template: context, acceptance criteria, definition of done).

## S: favourite shops, the one that looks splittable

**Contract**: R1 a heart on the shop page adds or removes a favourite; R2 favourites persist per account; R3 the home screen lists favourites first; R4 an empty list shows a hint.
**Tier**: S. A table, an endpoint, a heart button, and a sort: about 300 non-test lines over 8 files in one deployable.
**Triggers**: none. It is tempting to cut it into "favourites table", "favourites API", and "heart button", but those are layers: none is verifiable alone, and the whole thing fits one reviewable PR.
**Issues**: 1. "Customers can favourite shops and see them first" (full template, R1–R4 in its acceptance criteria).

## M: scheduled deliveries

**Contract**: R1 checkout offers delivery slots for the next 7 days; R2 a slot holds at most 20 orders; R3 a full slot shows as unavailable; R4 customers can reschedule until 2 hours before; R5 couriers see orders grouped by slot.
**Tier**: M. About 900 lines across checkout, ordering, and the courier app.
**Triggers**: size (vertical slices), feature flag (customers would see a half-built checkout).
**Issues**: parent "Scheduled deliveries" with
1. "Customers can book a delivery slot at checkout" (tracer bullet behind `scheduled_delivery`: R1, and slots shown to couriers as a plain list). Trigger: size.
2. "Full slots can't be booked" (R2, R3). Blocked by 1. Trigger: size, business rule.
3. "Customers can reschedule until 2 hours before" (R4). Blocked by 1; parallel with 2 (rescheduling touches the order page, capacity touches the slot service). Trigger: size, path.
4. "Couriers see orders grouped by slot" (R5). Blocked by 1; parallel with 2 and 3 (courier app only). Trigger: size, interface.
5. "Remove the scheduled_delivery flag". Blocked by 2, 3, 4. Trigger: feature flag.

## L: moving payments to a new provider

**Contract**: R1 every new payment goes through provider B; R2 saved cards migrate without customers re-entering them; R3 refunds of old payments still go through provider A; R4 provider A is switched off once no refund window is open; R5 payments must not double-charge during the switch.
**Tier**: L. Checkout, refunds, a card migration, and an ordered rollout, with one open question: whether provider B can import provider A's card tokens.
**Triggers**: unknowns (token import), refactor first (payment calls are spread across checkout), release ordering (expand, migrate, contract), feature flag.
**Issues**: parent "Payments move to provider B", which says the plan is re-evaluated when the spike closes, with
1. "Decide how saved cards move to provider B" (spike, time-boxed to 2 days, output an ADR). Trigger: unknowns.
2. "Checkout charges through one payment interface" (behavior-preserving refactor). Parallel with 1. Trigger: refactor first.
3. "New payments go through provider B behind a flag" (tracer bullet, R1, R5). Blocked by 1, 2. Trigger: release ordering (expand).
4. "Saved cards are migrated to provider B" (R2). Blocked by 3. Trigger: release ordering (migrate), data.
5. "Refunds of provider A payments still work" (R3). Blocked by 2; parallel with 3 and 4 (refund service only). Trigger: variants.
6. "Provider A is switched off" (R4). Blocked by 4, 5. Trigger: release ordering (contract).
7. "Remove the provider_b flag". Blocked by 6. Trigger: feature flag.

## XL: "Marketplace"

**Contract**: third-party sellers (onboarding, KYC, payouts), product reviews, a search rewrite, and a loyalty programme.
**Tier**: XL. Four features that each ship and make sense alone, well over 10 issues together.
**Triggers**: none apply: the contract itself needs splitting.
**Issues**: none. The reply recommends four contracts, in this order: seller onboarding and payouts (the rest depends on sellers existing); reviews; search; loyalty. Reviews, search, and loyalty can be designed in parallel once onboarding is agreed.

## Bug: orders charged twice on retry

**Contract**: a timeout during payment makes the app retry, and the retry charges again because the request carries no idempotency key. Fix: send one idempotency key per checkout attempt. 31 customers were charged twice last month.
**Tier**: S by size, moved to M by the trigger. Without the 31 customers, this would be one issue.
**Triggers**: data repair (refunding the double charges is its own verified job).
**Issues**: parent "Payment retries charge twice" with
1. "A payment retry never charges twice": a failing test that times out the first call and asserts one charge, plus the fix.
2. "Customers charged twice last month are refunded" (a one-off script with a dry run and a report). Parallel with 1 (a script, no shared files). Trigger: data repair.

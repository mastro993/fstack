# Readwell email renewals: approved plan

Tier: M (about 700 non-test lines across the nightly job, loans, a new confirm page, and the loan
history). Triggers: size, feature flag (members would see a half-built renew flow).

Parent: **Email reminders and renewals** (tracking issue).

1. **Members can renew from the due-date reminder** (tracer bullet, behind the `email_renewals`
   flag). The nightly job sends a due-date reminder with a signed Renew link; the link opens the
   confirm page; Renew renews the loan and shows the new due date. Keeps today's one-renewal limit.
   Trigger: size. Blocked by: nothing. Links: spec, ADR 0005, ADR 0006, prototype.
2. **Two renewals per loan, each recorded and shown in the loan history.** Renewals become their own
   rows; the limit is 2, from the desk and from the email; librarians see each renewal with its date
   and source. Trigger: size (business rule). Blocked by: nothing; parallel with 1 only if 1 keeps
   calling `renew()` unchanged. Links: spec, ADR 0004.
3. **Reminder 3 days before the due date, with the hold and overdue rules.** Adds the 3-days-before
   email; the button becomes a hold notice when a hold is waiting, and is absent once overdue.
   Trigger: size (business rules). Blocked by: 1. Links: spec, ADR 0006.
4. **Used, expired, tampered and returned links explain themselves.** The failure pages for the
   renew link. Trigger: size (error paths). Blocked by: 1. Links: spec, ADR 0005, prototype.
5. **Remove the email_renewals flag.** Trigger: feature flag. Blocked by: 2, 3, 4.

Order: 1 and 2 in parallel; then 3 and 4 in parallel; then 5.

| Requirement | Issue |
| --- | --- |
| Rule 1 (reminders 3 days before and on the due date) | 1 (due date), 3 (3 days before) |
| Rules 2, 6 (Renew button, confirm page) | 1 |
| Rule 3 (two renewals) | 2 |
| Rules 4, 5 (hold notice, overdue) | 3 |
| Rule 6 failures (used up, expired, returned, tampered) | 4 |
| Rule 7 (renewals in the history) | 2 |

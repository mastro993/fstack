# Readwell 2.0

Signed off by the library committee, 12 November.

## 1. Member accounts
Members get their own login (email and a one-time code; no passwords). They can see their loans and
holds, change their email, and renew from the website. Existing members are invited by email; the
desk can resend an invite.

## 2. Teacher priority on holds
Members flagged as teachers (by the desk) jump ahead of other members in a title's hold line, but
never ahead of another teacher. A teacher's hold expires after 3 days instead of 7. The desk sees why
a member is ahead in the line.

## 3. Statistics for librarians
A page for librarians with loans per month, the 20 most borrowed titles this year, the share of
loans returned late, and holds waiting longer than 30 days. Exportable as CSV for the committee.

## 4. Inter-library loans with Ashford
Members can request a title Readwell doesn't own from Ashford library. Requests go to Ashford's API;
when the copy arrives the desk checks it in as an inter-library loan, with Ashford's due date and no
renewals. Members see the request's status.

## 5. Move to Postgres
The database moves from SQLite to Postgres on the new host, with a one-night cutover, a rehearsal on
a copy of the data beforehand, and a way back to SQLite if the cutover fails.

## Acceptance
Each section has its own acceptance checks in the committee's minutes; every section must ship by
the end of the school year.

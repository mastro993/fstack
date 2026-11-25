# Overdue report

## Problem
The duty librarian phones members with long-overdue loans, but today they work it out by scrolling
the loans table by hand.

## Behavior
1. `node src/overdue-report.js` writes `overdue.csv` with one row per overdue loan: member name,
   member email, title, due date (YYYY-MM-DD), and days overdue.
2. Rows are sorted by days overdue, most overdue first.
3. With no overdue loans, the file has only the header row.
4. The nightly job (`src/reminders.js`) also emails the CSV, as an attachment, to the duty
   librarian's address in `DUTY_LIBRARIAN_EMAIL`, after sending the member reminders.
5. When `DUTY_LIBRARIAN_EMAIL` is not set, the job skips that email and logs one line saying so.

## Design
- Overdue means what `isOverdue` in `src/loans.js` already says.
- The CSV is built by one function shared by the script and the nightly job; commas and quotes in
  titles are escaped per RFC 4180.
- The email goes through the existing outbox, like the member reminders.

## Acceptance
- A loan 10 days overdue is listed above one 2 days overdue.
- A title containing a comma survives a round trip through a spreadsheet.
- With no overdue loans, the CSV is just the header.
- The nightly run puts exactly one email with the CSV in the outbox when the address is set, and
  none when it isn't.

## Open questions
None.

import { db } from './db.js';
import { isAlmostLate, isOverdue } from './loans.js';

// Nightly job (cron, 02:00). Email only: docs/adr/0001.
// Members get a reminder two days before a loan is due, then hear from us once it is overdue
// and every 7 days until the copy is back.
export function sendReminders(now = new Date()) {
  for (const loan of db.loans) {
    const member = db.members.find((m) => m.id === loan.memberId);
    const copy = db.copies.find((c) => c.id === loan.copyId);
    const title = db.titles.find((t) => t.id === copy.titleId);
    if (isAlmostLate(loan, now)) {
      db.outbox.push({
        to: member.email,
        subject: `Due soon: ${title.name}`,
        body: `Your loan of "${title.name}" was due on ${loan.dueDate.toISOString().slice(0, 10)}. Renew it from "My loans" or bring it back to the desk.`,
      });
      continue;
    }
    if (!isOverdue(loan, now)) continue;
    const daysOver = Math.floor((now - loan.dueDate) / 86_400_000);
    if (daysOver % 7 !== 0) continue;
    db.outbox.push({
      to: member.email,
      subject: `Overdue: ${title.name}`,
      body: `Your loan of "${title.name}" was due on ${loan.dueDate.toISOString().slice(0, 10)}. Please bring it back to the desk.`,
    });
  }
}

if (import.meta.url === `file://${process.argv[1]}`) sendReminders();

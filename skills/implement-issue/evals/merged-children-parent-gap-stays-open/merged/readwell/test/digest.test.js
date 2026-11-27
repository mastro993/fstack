import assert from 'node:assert/strict';
import { beforeEach, test } from 'node:test';
import { addDays, db } from '../src/db.js';
import { checkOut } from '../src/loans.js';
import { sendDeskDigest } from '../src/reminders.js';

const monday = new Date('2026-03-02T00:00:00Z');

beforeEach(() => {
  for (const table of Object.values(db)) table.length = 0;
  db.members.push({ id: 1, name: 'Ines Okafor', email: 'ines@example.org' }, { id: 2, name: 'Tom Reyes', email: 'tom@example.org' });
  db.titles.push({ id: 1, name: 'The Overstory' }, { id: 2, name: 'Piranesi' });
  db.copies.push({ id: 1, titleId: 1 }, { id: 2, titleId: 2 });
});

test('the Monday digest lists loans 14+ days overdue', () => {
  checkOut(1, 1, addDays(monday, -35));
  checkOut(2, 2, addDays(monday, -49));
  sendDeskDigest(monday);
  assert.equal(db.outbox.length, 1);
  assert.equal(db.outbox[0].to, 'desk@millbrook.org');
  assert.equal(db.outbox[0].body, 'Tom Reyes — Piranesi — 28 days overdue\nInes Okafor — The Overstory — 14 days overdue');
});

test('no digest when nothing is badly overdue', () => {
  checkOut(1, 1, addDays(monday, -28));
  sendDeskDigest(monday);
  assert.equal(db.outbox.length, 0);
});

test('no digest on other weekdays', () => {
  checkOut(1, 1, addDays(monday, -40));
  sendDeskDigest(addDays(monday, 1));
  assert.equal(db.outbox.length, 0);
});

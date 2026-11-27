import { db } from './db.js';

export function setRemindersOff(memberId, value) {
  const member = db.members.find((m) => m.id === memberId);
  member.remindersOff = value;
}

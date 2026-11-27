import { test } from "node:test";
import assert from "node:assert/strict";
import { createOrder, markPaid, ship } from "./orders.ts";
import { statusLabel } from "./labels.ts";

const items = [{ sku: "MUG-01", qty: 1, priceCents: 1200 }];
const at = new Date("2026-03-01T10:00:00Z");

test("labels follow the order through its life", () => {
  const order = createOrder("o1", items);
  assert.equal(statusLabel(order), "Awaiting payment");
  const paid = markPaid(order, at);
  assert.equal(statusLabel(paid), "Paid · ready to pick");
  assert.equal(statusLabel(ship(paid, "TRK9", at)), "Shipped · TRK9");
});

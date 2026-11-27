import { test } from "node:test";
import assert from "node:assert/strict";
import { createOrder, markPaid, ship, totalCents } from "./orders.ts";

const items = [{ sku: "MUG-01", qty: 2, priceCents: 1200 }];
const t0 = new Date("2026-03-01T10:00:00Z");
const t1 = new Date("2026-03-02T10:00:00Z");

test("an order without items is rejected", () => {
  assert.throws(() => createOrder("o1", []), /at least one item/);
});

test("the total is quantity times price over all items", () => {
  assert.equal(totalCents(createOrder("o1", items)), 2400);
});

test("a paid order ships with its tracking number", () => {
  const shipped = ship(markPaid(createOrder("o1", items), t0), "TRK1", t1);
  assert.equal(shipped.trackingNumber, "TRK1");
  assert.deepEqual(shipped.shippedAt, t1);
});

test("an unpaid order cannot ship", () => {
  assert.throws(() => ship(createOrder("o1", items), "TRK1", t1), /not paid/);
});

test("an order cannot be paid twice", () => {
  assert.throws(() => markPaid(markPaid(createOrder("o1", items), t0), t1), /already paid/);
});

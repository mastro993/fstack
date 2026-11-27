import { test } from "node:test";
import assert from "node:assert/strict";
import { createOrder, markPaid, ship } from "./orders.ts";
import { pickList } from "./fulfillment.ts";

const items = [{ sku: "MUG-01", qty: 1, priceCents: 1200 }];

test("the pick list holds paid, unshipped orders, oldest payment first", () => {
  const unpaid = createOrder("unpaid", items);
  const late = markPaid(createOrder("late", items), new Date("2026-03-02T00:00:00Z"));
  const early = markPaid(createOrder("early", items), new Date("2026-03-01T00:00:00Z"));
  const shipped = ship(markPaid(createOrder("shipped", items), new Date("2026-02-01T00:00:00Z")), "T", new Date());
  assert.deepEqual(pickList([unpaid, late, shipped, early]).map((o) => o.id), ["early", "late"]);
});

import { test, afterEach } from "node:test";
import assert from "node:assert/strict";
import { changedPrices, loadPrices } from "./feed.ts";

afterEach(() => {
  delete process.env.FEED_URL;
});

test("loads prices from the feed's /prices endpoint", async () => {
  process.env.FEED_URL = "http://feed.test";
  let requested = "";
  const impl = (async (url: string) => {
    requested = url;
    return Response.json([{ sku: "A", cents: 100 }]);
  }) as typeof fetch;
  assert.deepEqual(await loadPrices(impl), [{ sku: "A", cents: 100 }]);
  assert.equal(requested, "http://feed.test/prices");
});

test("only prices that differ from the last run count as changed", () => {
  const before = [{ sku: "A", cents: 100 }, { sku: "B", cents: 200 }];
  const after = [{ sku: "A", cents: 100 }, { sku: "B", cents: 250 }, { sku: "C", cents: 5 }];
  assert.deepEqual(changedPrices(before, after).map((p) => p.sku), ["B", "C"]);
});

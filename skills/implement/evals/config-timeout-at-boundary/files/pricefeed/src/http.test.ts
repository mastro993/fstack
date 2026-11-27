import { test, afterEach } from "node:test";
import assert from "node:assert/strict";
import { fetchJson } from "./http.ts";

afterEach(() => {
  delete process.env.HTTP_RETRIES;
});

function flaky(failures: number) {
  let calls = 0;
  const impl = (async () => {
    calls++;
    if (calls <= failures) return new Response("nope", { status: 503 });
    return Response.json({ ok: true });
  }) as typeof fetch;
  return { impl, calls: () => calls };
}

test("retries a failed request twice by default", async () => {
  const server = flaky(2);
  assert.deepEqual(await fetchJson("http://feed.test/x", server.impl), { ok: true });
  assert.equal(server.calls(), 3);
});

test("HTTP_RETRIES sets the number of retries", async () => {
  process.env.HTTP_RETRIES = "0";
  const server = flaky(1);
  await assert.rejects(fetchJson("http://feed.test/x", server.impl), /503/);
  assert.equal(server.calls(), 1);
});

test("a malformed HTTP_RETRIES is refused", async () => {
  process.env.HTTP_RETRIES = "lots";
  await assert.rejects(fetchJson("http://feed.test/x", flaky(0).impl), /HTTP_RETRIES/);
});

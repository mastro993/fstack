#!/usr/bin/env bash
# gateway/: branch feat/rate-limit, checked out and clean, adds per-client rate limiting in about
# 280 changed lines over 7 files. Three bugs it introduces:
#   G1 TokenBucket measures time in seconds (its tests pass seconds), but the middleware passes
#      Date.now() milliseconds, so buckets refill 1000 times too fast and nothing is ever limited.
#   G2 the middleware keys buckets on the raw X-Forwarded-For header instead of clientIp(), which
#      trusts it only from TRUSTED_PROXIES, so any client sends a fresh value per request and is
#      never limited.
#   G3 after answering 429 the middleware falls through to next(), so the handler runs anyway and
#      writes to a finished response.
# Decoys the review should leave alone:
#   D1 server.js sends Content-Length as body.length (wrong for non-ASCII): pre-existing, untouched.
#   D2 middleware.js declares `started` and never reads it: ESLint no-unused-vars reports it in CI.
#   D3 MemoryStore's sweep timer is unref()'d, so it never keeps the process alive.
# REVIEW.md asks reviewers to skip missing JSDoc and test coverage.
. "$(dirname "$0")/lib.sh"

new_repo gateway
mkdir -p src test .github/workflows
cat > package.json <<'EOF'
{
  "name": "gateway",
  "version": "1.4.0",
  "type": "module",
  "private": true,
  "scripts": {
    "start": "node src/server.js",
    "test": "node --test",
    "lint": "eslint ."
  }
}
EOF
cat > eslint.config.js <<'EOF'
export default [
  {
    files: ["**/*.js"],
    rules: { "no-unused-vars": "error", "no-undef": "error", eqeqeq: "error" },
  },
];
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm run lint
      - run: npm test
EOF
cat > REVIEW.md <<'EOF'
# Review guidance

strictness: balanced

- Don't flag missing JSDoc or missing test coverage; we track those separately.
- Anything that lets a client get around authentication or limits is Critical.
EOF
cat > README.md <<'EOF'
# gateway

The HTTP front door for the internal APIs. `npm test` runs the tests.

Configuration comes from the environment; see `src/config.js`.
EOF
cat > src/config.js <<'EOF'
function list(value) {
  return (value ?? "").split(",").map((s) => s.trim()).filter(Boolean);
}

export function loadConfig(env = process.env) {
  return {
    port: Number(env.PORT ?? 8080),
    trustedProxies: list(env.TRUSTED_PROXIES),
  };
}
EOF
cat > src/client-ip.js <<'EOF'
// The client's address. X-Forwarded-For is only believed when the direct peer is one of our own
// proxies; anyone else could put any address in it.
export function clientIp(req, trustedProxies) {
  const peer = req.socket.remoteAddress;
  if (!trustedProxies.includes(peer)) return peer;
  const forwarded = String(req.headers["x-forwarded-for"] ?? "").split(",").map((s) => s.trim()).filter(Boolean);
  return forwarded.at(-1) ?? peer;
}
EOF
cat > src/server.js <<'EOF'
import http from "node:http";
import { loadConfig } from "./config.js";

function send(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, { "Content-Type": "application/json", "Content-Length": body.length });
  res.end(body);
}

export function createApp(config) {
  const routes = {
    "/health": (req, res) => send(res, 200, { ok: true }),
    "/whoami": (req, res) => send(res, 200, { ip: req.socket.remoteAddress }),
  };
  return (req, res) => {
    const handler = routes[new URL(req.url, "http://x").pathname];
    if (!handler) return send(res, 404, { error: "not found" });
    return handler(req, res);
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const config = loadConfig();
  http.createServer(createApp(config)).listen(config.port);
}
EOF
cat > test/client-ip.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { clientIp } from "../src/client-ip.js";

const req = (peer, xff) => ({ socket: { remoteAddress: peer }, headers: xff ? { "x-forwarded-for": xff } : {} });

test("ignores X-Forwarded-For from an untrusted peer", () => {
  assert.equal(clientIp(req("203.0.113.9", "1.2.3.4"), ["10.0.0.1"]), "203.0.113.9");
});

test("believes X-Forwarded-For from a trusted proxy", () => {
  assert.equal(clientIp(req("10.0.0.1", "1.2.3.4"), ["10.0.0.1"]), "1.2.3.4");
});
EOF
commit "Gateway with health and whoami"

git checkout -q -b feat/rate-limit
mkdir -p src/ratelimit
cat > src/config.js <<'EOF'
function list(value) {
  return (value ?? "").split(",").map((s) => s.trim()).filter(Boolean);
}

function positive(value, fallback, name) {
  if (value === undefined || value === "") return fallback;
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0) throw new Error(`${name} must be a positive number, got ${value}`);
  return n;
}

export function loadConfig(env = process.env) {
  return {
    port: Number(env.PORT ?? 8080),
    trustedProxies: list(env.TRUSTED_PROXIES),
    rateLimit: {
      capacity: positive(env.RATE_LIMIT_BURST, 20, "RATE_LIMIT_BURST"),
      refillPerSecond: positive(env.RATE_LIMIT_PER_SECOND, 5, "RATE_LIMIT_PER_SECOND"),
    },
  };
}
EOF
cat > src/ratelimit/bucket.js <<'EOF'
// A token bucket: holds up to `capacity` tokens and gains `refillPerSecond` tokens per second.
// Each request takes one token; with none left, the request is refused. Time is in seconds.
export class TokenBucket {
  constructor({ capacity, refillPerSecond, now }) {
    this.capacity = capacity;
    this.refillPerSecond = refillPerSecond;
    this.tokens = capacity;
    this.updatedAt = now;
  }

  refill(now) {
    const elapsed = Math.max(0, now - this.updatedAt);
    this.tokens = Math.min(this.capacity, this.tokens + elapsed * this.refillPerSecond);
    this.updatedAt = now;
  }

  // Takes one token when there is one. Returns whether the request may go ahead.
  take(now) {
    this.refill(now);
    if (this.tokens < 1) return false;
    this.tokens -= 1;
    return true;
  }

  // Seconds until the next token, for Retry-After.
  waitSeconds(now) {
    this.refill(now);
    if (this.tokens >= 1) return 0;
    return Math.ceil((1 - this.tokens) / this.refillPerSecond);
  }

  toJSON() {
    return { capacity: this.capacity, refillPerSecond: this.refillPerSecond, tokens: this.tokens, updatedAt: this.updatedAt };
  }

  static fromJSON(data) {
    const bucket = new TokenBucket({ capacity: data.capacity, refillPerSecond: data.refillPerSecond, now: data.updatedAt });
    bucket.tokens = data.tokens;
    return bucket;
  }
}
EOF
cat > src/ratelimit/store.js <<'EOF'
// Buckets by client key. Async like the networked store that will replace it, so callers don't change.
export class MemoryStore {
  constructor({ ttlMs = 10 * 60 * 1000, sweepEveryMs = 60 * 1000 } = {}) {
    this.ttlMs = ttlMs;
    this.entries = new Map();
    this.timer = setInterval(() => this.sweep(Date.now()), sweepEveryMs);
    this.timer.unref();
  }

  async get(key) {
    const entry = this.entries.get(key);
    return entry ? entry.value : undefined;
  }

  async set(key, value) {
    this.entries.set(key, { value, touchedAt: Date.now() });
  }

  sweep(now) {
    for (const [key, entry] of this.entries) {
      if (now - entry.touchedAt > this.ttlMs) this.entries.delete(key);
    }
  }

  close() {
    clearInterval(this.timer);
  }
}
EOF
cat > src/ratelimit/middleware.js <<'EOF'
import { TokenBucket } from "./bucket.js";

// Limits each client to `capacity` requests in a burst and `refillPerSecond` on average.
// Over the limit, answers 429 with Retry-After.
export function rateLimit({ store, capacity, refillPerSecond, clock = () => Date.now() }) {
  return async (req, res, next) => {
    const started = Date.now();
    const key = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
    const now = clock();
    const saved = await store.get(key);
    const bucket = saved ? TokenBucket.fromJSON(saved) : new TokenBucket({ capacity, refillPerSecond, now });
    const allowed = bucket.take(now);
    await store.set(key, bucket.toJSON());
    if (!allowed) {
      res.statusCode = 429;
      res.setHeader("Retry-After", String(bucket.waitSeconds(now)));
      res.end("Too Many Requests");
    }
    return next();
  };
}
EOF
cat > src/server.js <<'EOF'
import http from "node:http";
import { loadConfig } from "./config.js";
import { rateLimit } from "./ratelimit/middleware.js";
import { MemoryStore } from "./ratelimit/store.js";

function send(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, { "Content-Type": "application/json", "Content-Length": body.length });
  res.end(body);
}

export function createApp(config, { store = new MemoryStore() } = {}) {
  const routes = {
    "/health": (req, res) => send(res, 200, { ok: true }),
    "/whoami": (req, res) => send(res, 200, { ip: req.socket.remoteAddress }),
  };
  const limit = rateLimit({ store, ...config.rateLimit });
  return (req, res) =>
    limit(req, res, () => {
      const handler = routes[new URL(req.url, "http://x").pathname];
      if (!handler) return send(res, 404, { error: "not found" });
      return handler(req, res);
    });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const config = loadConfig();
  http.createServer(createApp(config)).listen(config.port);
}
EOF
cat > test/bucket.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { TokenBucket } from "../src/ratelimit/bucket.js";

test("allows a burst up to capacity", () => {
  const bucket = new TokenBucket({ capacity: 3, refillPerSecond: 1, now: 0 });
  assert.deepEqual([bucket.take(0), bucket.take(0), bucket.take(0), bucket.take(0)], [true, true, true, false]);
});

test("refills over time", () => {
  const bucket = new TokenBucket({ capacity: 2, refillPerSecond: 1, now: 0 });
  bucket.take(0);
  bucket.take(0);
  assert.equal(bucket.take(0.5), false);
  assert.equal(bucket.take(1), true);
});

test("never holds more than capacity", () => {
  const bucket = new TokenBucket({ capacity: 2, refillPerSecond: 10, now: 0 });
  bucket.refill(100);
  assert.equal(bucket.tokens, 2);
});

test("waitSeconds rounds up to whole seconds", () => {
  const bucket = new TokenBucket({ capacity: 1, refillPerSecond: 0.5, now: 0 });
  bucket.take(0);
  assert.equal(bucket.waitSeconds(0), 2);
});

test("round-trips through JSON", () => {
  const bucket = new TokenBucket({ capacity: 5, refillPerSecond: 2, now: 10 });
  bucket.take(10);
  const copy = TokenBucket.fromJSON(JSON.parse(JSON.stringify(bucket)));
  assert.deepEqual(copy.toJSON(), bucket.toJSON());
});
EOF
cat > test/middleware.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { rateLimit } from "../src/ratelimit/middleware.js";
import { MemoryStore } from "../src/ratelimit/store.js";

function fakeRes() {
  return {
    statusCode: 200,
    headers: {},
    body: "",
    setHeader(name, value) {
      this.headers[name] = value;
    },
    end(body) {
      this.body = body;
    },
  };
}

test("lets requests through under the limit", async () => {
  const store = new MemoryStore();
  const limit = rateLimit({ store, capacity: 2, refillPerSecond: 1, clock: () => 0 });
  let calls = 0;
  await limit({ headers: {}, socket: { remoteAddress: "198.51.100.7" } }, fakeRes(), () => calls++);
  await limit({ headers: {}, socket: { remoteAddress: "198.51.100.7" } }, fakeRes(), () => calls++);
  assert.equal(calls, 2);
  store.close();
});

test("answers 429 with Retry-After over the limit", async () => {
  const store = new MemoryStore();
  const limit = rateLimit({ store, capacity: 1, refillPerSecond: 1, clock: () => 0 });
  const req = { headers: {}, socket: { remoteAddress: "198.51.100.7" } };
  await limit(req, fakeRes(), () => {});
  const res = fakeRes();
  await limit(req, res, () => {});
  assert.equal(res.statusCode, 429);
  assert.equal(res.headers["Retry-After"], "1");
  store.close();
});
EOF
cat > test/config.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { loadConfig } from "../src/config.js";

test("rate limit defaults", () => {
  assert.deepEqual(loadConfig({}).rateLimit, { capacity: 20, refillPerSecond: 5 });
});

test("rejects a non-positive rate", () => {
  assert.throws(() => loadConfig({ RATE_LIMIT_PER_SECOND: "0" }), /positive/);
});
EOF
cat > test/store.test.js <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { MemoryStore } from "../src/ratelimit/store.js";

test("returns what was set", async () => {
  const store = new MemoryStore();
  await store.set("a", { tokens: 1 });
  assert.deepEqual(await store.get("a"), { tokens: 1 });
  store.close();
});

test("sweeps entries idle longer than the ttl", async () => {
  const store = new MemoryStore({ ttlMs: 1000 });
  await store.set("a", { tokens: 1 });
  store.sweep(Date.now() + 2000);
  assert.equal(await store.get("a"), undefined);
  store.close();
});

test("keeps entries touched within the ttl", async () => {
  const store = new MemoryStore({ ttlMs: 1000 });
  await store.set("a", { tokens: 1 });
  store.sweep(Date.now() + 500);
  assert.deepEqual(await store.get("a"), { tokens: 1 });
  store.close();
});
EOF
cat >> README.md <<'EOF'

## Rate limiting

Every client gets a token bucket: `RATE_LIMIT_BURST` requests at once (default 20), refilled at
`RATE_LIMIT_PER_SECOND` (default 5). Over the limit the gateway answers `429` with `Retry-After`.
EOF
commit "Rate limit clients with a token bucket" limits-dev
cd "$ROOT"

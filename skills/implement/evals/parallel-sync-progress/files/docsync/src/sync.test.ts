import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdir, mkdtemp, readdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { sync, type Source } from "./sync.ts";

function fakeSource(ids: string[]) {
  const fetched: string[] = [];
  const source: Source = {
    list: async () => ids,
    fetch: async (id) => {
      fetched.push(id);
      return { id, body: `# ${id}\n` };
    },
  };
  return { source, fetched };
}

async function workdir() {
  const dir = await mkdtemp(join(tmpdir(), "docsync-"));
  return { out: join(dir, "out"), state: join(dir, "state", "progress.json") };
}

test("saves every listed document", async () => {
  const { out, state } = await workdir();
  const { source } = fakeSource(["intro", "setup"]);
  assert.equal(await sync(source, out, state, 1), 2);
  assert.deepEqual((await readdir(out)).sort(), ["intro.md", "setup.md"]);
  assert.equal(await readFile(join(out, "intro.md"), "utf8"), "# intro\n");
});

test("skips documents a previous sync finished", async () => {
  const { out, state } = await workdir();
  await mkdir(join(state, ".."), { recursive: true });
  await writeFile(state, JSON.stringify({ done: ["intro"] }));
  const { source, fetched } = fakeSource(["intro", "setup"]);
  await sync(source, out, state, 1);
  assert.deepEqual(fetched, ["setup"]);
});

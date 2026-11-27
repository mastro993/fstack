import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { loadProgress, markDone } from "./progress.ts";

export type Doc = { id: string; body: string };

export interface Source {
  list(): Promise<string[]>;
  fetch(id: string): Promise<Doc>;
}

export async function sync(source: Source, outDir: string, stateFile: string, concurrency = 4): Promise<number> {
  const { done } = await loadProgress(stateFile);
  const queue = (await source.list()).filter((id) => !done.includes(id));
  await mkdir(outDir, { recursive: true });

  let saved = 0;
  async function worker(): Promise<void> {
    for (let id = queue.shift(); id !== undefined; id = queue.shift()) {
      const doc = await source.fetch(id);
      await writeFile(join(outDir, `${doc.id}.md`), doc.body);
      await markDone(stateFile, doc.id);
      saved++;
    }
  }
  await Promise.all(Array.from({ length: concurrency }, worker));
  return saved;
}

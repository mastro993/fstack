import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";

export type Progress = { done: string[] };

export async function loadProgress(file: string): Promise<Progress> {
  try {
    return JSON.parse(await readFile(file, "utf8"));
  } catch {
    return { done: [] };
  }
}

export async function markDone(file: string, id: string): Promise<void> {
  const progress = await loadProgress(file);
  if (!progress.done.includes(id)) progress.done.push(id);
  await mkdir(dirname(file), { recursive: true });
  await writeFile(file, JSON.stringify(progress, null, 2));
}

import { sync, type Doc, type Source } from "./sync.ts";

const api = process.env.DOCS_API ?? "https://docs.example.org/api";

async function getJson(path: string): Promise<unknown> {
  const response = await fetch(`${api}${path}`);
  if (!response.ok) throw new Error(`GET ${path} failed with ${response.status}`);
  return response.json();
}

const source: Source = {
  list: async () => (await getJson("/docs")) as string[],
  fetch: async (id) => (await getJson(`/docs/${encodeURIComponent(id)}`)) as Doc,
};

const saved = await sync(source, "out", "state/progress.json");
console.log(`saved ${saved} documents`);

import { getEnv } from "./env.ts";
import { fetchJson } from "./http.ts";

export type Price = { sku: string; cents: number };

export async function loadPrices(fetchImpl: typeof fetch = fetch): Promise<Price[]> {
  const base = getEnv("FEED_URL");
  if (!base) throw new Error("FEED_URL is not set");
  const body = await fetchJson(`${base}/prices`, fetchImpl);
  if (!Array.isArray(body)) throw new Error("price feed did not return a list");
  return body.map((row) => ({ sku: String(row.sku), cents: Number(row.cents) }));
}

export function changedPrices(before: Price[], after: Price[]): Price[] {
  const old = new Map(before.map((p) => [p.sku, p.cents]));
  return after.filter((p) => old.get(p.sku) !== p.cents);
}

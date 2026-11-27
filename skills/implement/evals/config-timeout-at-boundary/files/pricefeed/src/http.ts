import { getEnv } from "./env.ts";

export async function fetchJson(url: string, fetchImpl: typeof fetch = fetch): Promise<unknown> {
  let retries = 2;
  const raw = getEnv("HTTP_RETRIES");
  if (raw !== undefined) {
    const parsed = parseInt(raw, 10);
    if (isNaN(parsed) || parsed < 0) throw new Error(`HTTP_RETRIES must be a non-negative integer, got "${raw}"`);
    retries = parsed;
  }
  if (typeof url !== "string" || url.length === 0) throw new Error("fetchJson needs a url");

  let lastError: unknown;
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const response = await fetchImpl(url);
      if (!response.ok) throw new Error(`GET ${url} failed with ${response.status}`);
      return await response.json();
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}

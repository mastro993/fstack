import { changedPrices, loadPrices, type Price } from "./feed.ts";
import { getEnv } from "./env.ts";

if (!getEnv("FEED_URL")) {
  console.error("FEED_URL is not set");
  process.exit(1);
}

let last: Price[] = [];
setInterval(async () => {
  const next = await loadPrices();
  for (const price of changedPrices(last, next)) console.log(`${price.sku}: ${price.cents}`);
  last = next;
}, 5 * 60 * 1000);

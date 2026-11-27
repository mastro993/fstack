import type { Order } from "./orders.ts";

export function pickList(orders: Order[]): Order[] {
  return orders
    .filter((order) => order.isPaid && !order.isShipped)
    .sort((a, b) => (a.paidAt?.getTime() ?? 0) - (b.paidAt?.getTime() ?? 0));
}

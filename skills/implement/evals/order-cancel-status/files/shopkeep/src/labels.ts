import type { Order } from "./orders.ts";

export function statusLabel(order: Order): string {
  if (order.isShipped && !order.isPaid) return "Shipped (unpaid)";
  if (order.isShipped) return `Shipped · ${order.trackingNumber}`;
  if (order.isPaid) return "Paid · ready to pick";
  return "Awaiting payment";
}

export type LineItem = { sku: string; qty: number; priceCents: number };

export type Order = {
  id: string;
  items: LineItem[];
  isPaid: boolean;
  isShipped: boolean;
  paidAt?: Date;
  shippedAt?: Date;
  trackingNumber?: string;
};

export function createOrder(id: string, items: LineItem[]): Order {
  if (items.length === 0) throw new Error("an order needs at least one item");
  return { id, items, isPaid: false, isShipped: false };
}

export function totalCents(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.qty * item.priceCents, 0);
}

export function markPaid(order: Order, at: Date): Order {
  if (order.isPaid) throw new Error(`order ${order.id} is already paid`);
  return { ...order, isPaid: true, paidAt: at };
}

export function ship(order: Order, trackingNumber: string, at: Date): Order {
  if (!order.isPaid) throw new Error(`order ${order.id} is not paid`);
  if (order.isShipped) throw new Error(`order ${order.id} is already shipped`);
  return { ...order, isShipped: true, shippedAt: at, trackingNumber };
}

export function isOpen(order: Order): boolean {
  return !order.isShipped;
}

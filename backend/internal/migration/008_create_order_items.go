// Package migration provides database schema migration scripts.
package migration

// CreateOrderItemsTableSQL creates the order_items table.
const CreateOrderItemsTableSQL = `
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_image TEXT NOT NULL DEFAULT '',
    price DECIMAL(15,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 1,
    shop_id UUID NOT NULL,
    shop_name VARCHAR(255) NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_order_items_order
    ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_shop
    ON order_items(shop_id);
`

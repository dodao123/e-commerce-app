// Package migration provides database schema migration scripts.
package migration

// CreateCartItemsTableSQL creates the cart_items table.
// Links buyer (user_id) to product (product_id → shops → seller).
const CreateCartItemsTableSQL = `
CREATE TABLE IF NOT EXISTS cart_items (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity   INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_user
    ON cart_items (user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product
    ON cart_items (product_id);
`

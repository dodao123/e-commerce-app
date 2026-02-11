// Package migration provides database schema migration scripts.
package migration

// CreateProductsTableSQL creates the products table.
// Images stored as TEXT[] (PostgreSQL array). Video as URL string.
// Folder path derived from shop_id + product id at runtime.
const CreateProductsTableSQL = `
CREATE TABLE IF NOT EXISTS products (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id           UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    name              VARCHAR(120) NOT NULL,
    description       TEXT NOT NULL,
    category          VARCHAR(50) NOT NULL,
    price             NUMERIC(12, 2) NOT NULL DEFAULT 0,
    stock             INT NOT NULL DEFAULT 0,
    base_shipping_fee NUMERIC(10, 2) NOT NULL DEFAULT 0,
    condition         VARCHAR(10) NOT NULL DEFAULT 'new',
    condition_note    VARCHAR(200) DEFAULT '',
    images            TEXT[] DEFAULT '{}',
    video_url         TEXT DEFAULT '',
    status            VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_shop ON products (shop_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products (category);
CREATE INDEX IF NOT EXISTS idx_products_status ON products (status);
CREATE INDEX IF NOT EXISTS idx_products_price ON products (price);
`

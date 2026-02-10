// Package migration provides database schema migration scripts.
package migration

// CreateShopsTableSQL creates the shops table for seller shop information.
// Stores business details and identity verification data.
const CreateShopsTableSQL = `
CREATE TABLE IF NOT EXISTS shops (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id            UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shop_name            VARCHAR(100) NOT NULL,
    category             VARCHAR(50) NOT NULL,
    province             VARCHAR(100) NOT NULL,
    district             VARCHAR(100) NOT NULL,
    ward                 VARCHAR(100) NOT NULL,
    detail_address       TEXT NOT NULL,
    email                VARCHAR(255) NOT NULL,
    phone                VARCHAR(20) NOT NULL,
    nationality          VARCHAR(100) NOT NULL,
    national_id_number   VARCHAR(50) NOT NULL,
    full_name            VARCHAR(255) NOT NULL DEFAULT '',
    is_verified          BOOLEAN NOT NULL DEFAULT FALSE,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_seller_shop UNIQUE (seller_id)
);

CREATE INDEX IF NOT EXISTS idx_shops_seller ON shops (seller_id);
CREATE INDEX IF NOT EXISTS idx_shops_category ON shops (category);
CREATE INDEX IF NOT EXISTS idx_shops_verified ON shops (is_verified);
CREATE INDEX IF NOT EXISTS idx_shops_active ON shops (is_active);
`

// Package migration provides database schema migration scripts.
package migration

// AddCoordinatesToShopsAndAddressesSQL adds latitude and longitude to shops and delivery_addresses.
// Also enables earthdistance extension.
const AddCoordinatesToShopsAndAddressesSQL = `
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

ALTER TABLE shops 
    ADD COLUMN IF NOT EXISTS latitude NUMERIC(10, 7) NOT NULL DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS longitude NUMERIC(10, 7) NOT NULL DEFAULT 0.0;

ALTER TABLE delivery_addresses
    ADD COLUMN IF NOT EXISTS latitude NUMERIC(10, 7) NOT NULL DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS longitude NUMERIC(10, 7) NOT NULL DEFAULT 0.0;

-- Create indexes for performance on spatial queries (optional but recommended for earthdistance)
CREATE INDEX IF NOT EXISTS idx_shops_location ON shops USING gist (ll_to_earth(latitude, longitude));
CREATE INDEX IF NOT EXISTS idx_delivery_addresses_location ON delivery_addresses USING gist (ll_to_earth(latitude, longitude));
`

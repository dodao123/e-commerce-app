// Package migration provides database schema migration scripts.
package migration

// AlterOrdersAddShipperSQL adds shipper info to orders table.
const AlterOrdersAddShipperSQL = `
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipper_id UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS shipper_name VARCHAR(100) DEFAULT '',
ADD COLUMN IF NOT EXISTS shipper_phone VARCHAR(20) DEFAULT '';
`

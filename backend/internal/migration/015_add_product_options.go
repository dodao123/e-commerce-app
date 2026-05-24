// Package migration provides database schema migration scripts.
package migration

// AddProductOptionsSQL adds JSONB options column to products.
const AddProductOptionsSQL = `
ALTER TABLE products
ADD COLUMN IF NOT EXISTS options JSONB DEFAULT '[]';
`

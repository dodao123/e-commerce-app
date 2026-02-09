// Package migration provides database schema migration scripts.
package migration

// AddPasswordHashSQL adds password_hash column to users table
// for email/password authentication alongside OAuth providers.
const AddPasswordHashSQL = `
ALTER TABLE users
ADD COLUMN IF NOT EXISTS password_hash TEXT DEFAULT '';
`

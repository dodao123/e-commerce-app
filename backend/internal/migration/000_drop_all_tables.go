// Package migration provides database schema migration scripts.
package migration

// DropAllTablesSQL drops all tables in the correct order (respecting foreign keys).
const DropAllTablesSQL = `
-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS shops CASCADE;
DROP TABLE IF EXISTS user_auth_providers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
`

// Package migration provides database schema migration scripts.
package migration

import (
	"database/sql"
	"fmt"
	"log"
)

// migrationEntry holds a migration name and its SQL statement.
type migrationEntry struct {
	Name string
	SQL  string
}

// allMigrations returns the ordered list of all migrations.
func allMigrations() []migrationEntry {
	return []migrationEntry{
		{Name: "001_create_users", SQL: CreateUsersTableSQL},
		{Name: "002_create_auth_providers", SQL: CreateAuthProvidersTableSQL},
		{Name: "002_create_shops", SQL: CreateShopsTableSQL},
		{Name: "003_add_password_hash", SQL: AddPasswordHashSQL},
		{Name: "004_create_products", SQL: CreateProductsTableSQL},
	}
}

// RunAll executes all pending migrations sequentially.
func RunAll(database *sql.DB) error {
	for _, entry := range allMigrations() {
		log.Printf("🔄 Running migration: %s", entry.Name)

		if _, err := database.Exec(entry.SQL); err != nil {
			return fmt.Errorf("migration %s failed: %w", entry.Name, err)
		}

		log.Printf("✅ Migration complete: %s", entry.Name)
	}

	return nil
}

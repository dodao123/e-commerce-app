// Package main provides a database reset utility.
package main

import (
	"delivery-app/backend/internal/config"
	"delivery-app/backend/internal/database"
	"delivery-app/backend/internal/envloader"
	"delivery-app/backend/internal/migration"
	"log"

	_ "github.com/lib/pq"
)

// main drops all tables and re-runs migrations.
func main() {
	// Load .env file
	if err := envloader.Load(".env"); err != nil {
		log.Printf("⚠️ .env file not found, using system env vars")
	}

	// Load configuration
	cfg := config.Load()

	// Connect to PostgreSQL
	db, err := database.NewPostgresDB(&cfg.Database)
	if err != nil {
		log.Fatalf("❌ Database connection failed: %v", err)
	}
	defer db.Close()

	// Drop all tables
	log.Println("🗑️  Dropping all tables...")
	
	// Create public schema if not exists
	if _, err := db.Pool.Exec("CREATE SCHEMA IF NOT EXISTS public"); err != nil {
		log.Printf("⚠️ Schema creation warning: %v", err)
	}
	
	if _, err := db.Pool.Exec(migration.DropAllTablesSQL); err != nil {
		log.Fatalf("❌ Failed to drop tables: %v", err)
	}
	log.Println("✅ All tables dropped")

	// Re-run migrations
	log.Println("🔄 Running migrations...")
	if err := migration.RunAll(db.Pool); err != nil {
		log.Fatalf("❌ Migration failed: %v", err)
	}

	log.Println("✅ Database reset complete!")
}

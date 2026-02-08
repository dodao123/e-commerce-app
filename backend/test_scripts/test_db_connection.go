// Package main provides a script to test PostgreSQL database connectivity.
package main

import (
	"delivery-app/backend/internal/config"
	"delivery-app/backend/internal/database"
	"delivery-app/backend/internal/envloader"
	"fmt"
	"log"
	"time"
)

// main loads config from .env and tests the database connection.
func main() {
	fmt.Println("=== Database Connection Test ===")
	fmt.Println()

	// Load .env from parent directory
	if err := envloader.Load("../.env"); err != nil {
		// Try current directory fallback
		if err2 := envloader.Load(".env"); err2 != nil {
			log.Printf("⚠️  No .env file found, using system env vars")
		}
	}

	cfg := config.Load()
	printConfig(&cfg.Database)

	// Attempt connection
	fmt.Println("🔄 Connecting to PostgreSQL...")
	startTime := time.Now()

	db, err := database.NewPostgresDB(&cfg.Database)
	if err != nil {
		log.Fatalf("❌ Connection FAILED: %v", err)
	}
	defer db.Close()

	elapsed := time.Since(startTime)
	fmt.Printf("✅ Connection SUCCESS (took %v)\n\n", elapsed)

	// Run health check
	runHealthCheck(db)

	// Query server version
	queryServerVersion(db)
}

// printConfig displays the database configuration (password masked).
func printConfig(dbCfg *config.DatabaseConfig) {
	fmt.Printf("  Host:     %s\n", dbCfg.Host)
	fmt.Printf("  Port:     %s\n", dbCfg.Port)
	fmt.Printf("  User:     %s\n", dbCfg.User)
	fmt.Printf("  Password: %s\n", maskPassword(dbCfg.Password))
	fmt.Printf("  Database: %s\n", dbCfg.DBName)
	fmt.Printf("  SSLMode:  %s\n\n", dbCfg.SSLMode)
}

// maskPassword hides the password for display purposes.
func maskPassword(password string) string {
	if len(password) == 0 {
		return "(empty)"
	}
	return "****"
}

// runHealthCheck pings the database to verify connectivity.
func runHealthCheck(db *database.PostgresDB) {
	fmt.Print("🏥 Health Check (Ping)... ")
	if err := db.HealthCheck(); err != nil {
		fmt.Printf("FAILED: %v\n", err)
	} else {
		fmt.Println("OK")
	}
}

// queryServerVersion retrieves and displays the PostgreSQL server version.
func queryServerVersion(db *database.PostgresDB) {
	var version string
	err := db.Pool.QueryRow("SELECT version()").Scan(&version)
	if err != nil {
		fmt.Printf("❌ Version query failed: %v\n", err)
		return
	}
	fmt.Printf("📦 Server: %s\n", version)
}

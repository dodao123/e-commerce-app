// Package main is the entry point for the Delivery App API server.
package main

import (
	"delivery-app/backend/internal/config"
	"delivery-app/backend/internal/database"
	"delivery-app/backend/internal/envloader"
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/router"
	"fmt"
	"log"
	"net/http"
)

// main initializes configuration, database, router, and starts the server.
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
		log.Printf("⚠️ Database connection failed: %v", err)
		log.Println("📡 Server will start without database")
	} else {
		defer db.Close()
	}

	// Setup router and middleware
	mux := router.NewRouter()
	handler := middleware.ApplyCORS(middleware.ApplyLogger(mux))

	// Start HTTP server
	addr := fmt.Sprintf(":%s", cfg.ServerPort)
	fmt.Printf("🚀 Delivery API Server starting on port %s\n", addr)
	fmt.Println("📍 Health: http://localhost:" + cfg.ServerPort + "/api/v1/health")

	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatalf("❌ Server failed: %v", err)
	}
}

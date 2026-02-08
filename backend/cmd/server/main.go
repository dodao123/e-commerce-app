// Package main is the entry point for the Delivery App API server.
package main

import (
	"delivery-app/backend/internal/config"
	"delivery-app/backend/internal/database"
	"delivery-app/backend/internal/envloader"
	"delivery-app/backend/internal/handler"
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/migration"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/router"
	"delivery-app/backend/internal/service"
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

		// Run database migrations
		if err := migration.RunAll(db.Pool); err != nil {
			log.Printf("⚠️ Migration failed: %v", err)
		}
	}

	// Initialize services
	jwtService := service.NewJWTService(&cfg.Auth)
	googleVerifier := service.NewGoogleVerifier(cfg.Auth.GoogleClientID)
	facebookVerifier := service.NewFacebookVerifier(
		cfg.Auth.FacebookAppID, cfg.Auth.FacebookSecret,
	)

	// Initialize repositories
	var authHandler *handler.AuthHandler
	if db != nil {
		userRepo := repository.NewPostgresUserRepository(db.Pool)
		authProviderRepo := repository.NewPostgresAuthProviderRepository(db.Pool)

		authHandler = handler.NewAuthHandler(
			userRepo, authProviderRepo,
			jwtService, googleVerifier, facebookVerifier,
		)
	}

	// Setup router and middleware
	mux := router.NewRouter(authHandler, jwtService)
	httpHandler := middleware.ApplyCORS(middleware.ApplyLogger(mux))

	// Start HTTP server
	addr := fmt.Sprintf(":%s", cfg.ServerPort)
	fmt.Printf("🚀 Delivery API Server starting on port %s\n", addr)
	fmt.Println("📍 Health: http://localhost:" + cfg.ServerPort + "/api/v1/health")
	fmt.Println("🔐 Auth:   POST /api/v1/auth/google")
	fmt.Println("🔐 Auth:   POST /api/v1/auth/facebook")
	fmt.Println("🔐 Auth:   POST /api/v1/auth/role (protected)")

	if err := http.ListenAndServe(addr, httpHandler); err != nil {
		log.Fatalf("❌ Server failed: %v", err)
	}
}

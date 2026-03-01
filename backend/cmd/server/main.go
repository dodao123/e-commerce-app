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
	"path/filepath"
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
	bcryptService := service.NewBcryptService()
	googleVerifier := service.NewGoogleVerifier(cfg.Auth.GoogleClientID)
	facebookVerifier := service.NewFacebookVerifier(
		cfg.Auth.FacebookAppID, cfg.Auth.FacebookSecret,
	)

	// Initialize handlers
	var authHandler *handler.AuthHandler
	var emailAuthHandler *handler.EmailAuthHandler
	var shopHandler *handler.ShopHandler
	var productHandler *handler.ProductHandler
	var cartHandler *handler.CartHandler

	// Image service (for bg removal + uploads)
	uploadRoot := filepath.Join(".", "uploads")
	imageService := service.NewImageService(
		uploadRoot, "http://localhost:5050")

	if db != nil {
		userRepo := repository.NewPostgresUserRepository(db.Pool)
		authProviderRepo := repository.NewPostgresAuthProviderRepository(db.Pool)
		shopRepo := repository.NewPostgresShopRepository(db.Pool)
		productRepo := repository.NewPostgresProductRepository(db.Pool)

		shopService := service.NewShopService(shopRepo, userRepo)
		productService := service.NewProductService(
			productRepo, shopRepo, imageService)

		authHandler = handler.NewAuthHandler(
			userRepo, authProviderRepo,
			jwtService, googleVerifier, facebookVerifier,
		)

		emailAuthHandler = handler.NewEmailAuthHandler(
			userRepo, jwtService, bcryptService,
		)

		shopHandler = handler.NewShopHandler(shopService)
		productHandler = handler.NewProductHandler(
			productService, imageService)

		// Cart DI chain
		cartRepo := repository.NewPostgresCartRepository(db.Pool)
		cartService := service.NewCartService(cartRepo, productRepo)
		cartHandler = handler.NewCartHandler(cartService)
	}

	// Setup router and middleware
	mux := router.NewRouter(
		authHandler, emailAuthHandler,
		shopHandler, productHandler, cartHandler, jwtService)
	httpHandler := middleware.ApplyCORS(middleware.ApplyLogger(mux))

	// Start HTTP server
	addr := fmt.Sprintf(":%s", cfg.ServerPort)
	fmt.Printf("🚀 Delivery API Server starting on port %s\n", addr)
	printRoutes(cfg.ServerPort)

	if err := http.ListenAndServe(addr, httpHandler); err != nil {
		log.Fatalf("❌ Server failed: %v", err)
	}
}

// printRoutes lists all available API endpoints.
func printRoutes(port string) {
	base := "http://localhost:" + port
	fmt.Println("📍 Health:    " + base + "/api/v1/health")
	fmt.Println("🔐 Register: POST " + base + "/api/v1/auth/register")
	fmt.Println("🔐 Login:    POST " + base + "/api/v1/auth/login")
	fmt.Println("🔐 Google:   POST " + base + "/api/v1/auth/google")
	fmt.Println("🔐 Facebook: POST " + base + "/api/v1/auth/facebook")
	fmt.Println("🔐 Role:     POST " + base + "/api/v1/auth/role (JWT)")
	fmt.Println("🏪 Shop:     POST " + base + "/api/v1/shops (JWT)")
	fmt.Println("🏪 My Shop:  GET  " + base + "/api/v1/shops/me (JWT)")
	fmt.Println("📦 Products: POST " + base + "/api/v1/products (JWT)")
	fmt.Println("📦 List:     GET  " + base + "/api/v1/products (JWT)")
	fmt.Println("📦 Detail:   GET  " + base + "/api/v1/products/{id}")
	fmt.Println("📦 Upload:   POST " + base + "/api/v1/products/{id}/images")
	fmt.Println("🛒 Cart:     GET  " + base + "/api/v1/cart (JWT)")
	fmt.Println("🛒 Add:      POST " + base + "/api/v1/cart/items (JWT)")
	fmt.Println("🛒 Update:   PUT  " + base + "/api/v1/cart/items/{id} (JWT)")
	fmt.Println("🛒 Remove:   DEL  " + base + "/api/v1/cart/items/{id} (JWT)")
	fmt.Println("🛒 Count:    GET  " + base + "/api/v1/cart/count (JWT)")
}

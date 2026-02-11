// Package router configures the API routes for the application.
package router

import (
	"delivery-app/backend/internal/handler"
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/service"
	"net/http"
)

// NewRouter creates and configures the HTTP router with all API routes.
func NewRouter(
	authHandler *handler.AuthHandler,
	emailAuthHandler *handler.EmailAuthHandler,
	shopHandler *handler.ShopHandler,
	productHandler *handler.ProductHandler,
	jwtService *service.JWTService,
) *http.ServeMux {
	mux := http.NewServeMux()

	healthHandler := handler.NewHealthHandler()

	// Health check
	mux.HandleFunc("/api/v1/health", healthHandler.Handle)

	// Social auth routes (public)
	mux.HandleFunc("/api/v1/auth/google", authHandler.HandleGoogleLogin)
	mux.HandleFunc("/api/v1/auth/facebook", authHandler.HandleFacebookLogin)

	// Email auth routes (public)
	mux.HandleFunc("/api/v1/auth/register", emailAuthHandler.HandleRegister)
	mux.HandleFunc("/api/v1/auth/login", emailAuthHandler.HandleLogin)

	// Protected routes (requires JWT)
	authGuard := middleware.AuthGuard(jwtService)
	mux.Handle("/api/v1/auth/role",
		authGuard(http.HandlerFunc(authHandler.HandleUpdateRole)),
	)

	// Shop routes (protected, requires JWT)
	if shopHandler != nil {
		mux.Handle("/api/v1/shops",
			authGuard(http.HandlerFunc(shopHandler.HandleCreateShop)),
		)
		mux.Handle("/api/v1/shops/me",
			authGuard(http.HandlerFunc(shopHandler.HandleGetMyShop)),
		)
		mux.Handle("/api/v1/shops/{id}",
			authGuard(http.HandlerFunc(shopHandler.HandleUpdateShop)),
		)
	}

	// Product routes (protected, requires JWT)
	if productHandler != nil {
		mux.Handle("/api/v1/products",
			authGuard(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				switch r.Method {
				case http.MethodPost:
					productHandler.HandleCreateProduct(w, r)
				case http.MethodGet:
					productHandler.HandleListProducts(w, r)
				default:
					http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
				}
			})),
		)
		mux.Handle("/api/v1/products/{id}",
			authGuard(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				switch r.Method {
				case http.MethodGet:
					productHandler.HandleGetProduct(w, r)
				case http.MethodPut:
					productHandler.HandleUpdateProduct(w, r)
				case http.MethodDelete:
					productHandler.HandleDeleteProduct(w, r)
				default:
					http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
				}
			})),
		)
		mux.Handle("/api/v1/products/{id}/images",
			authGuard(http.HandlerFunc(
				productHandler.HandleUploadImages)),
		)
	}

	// Static file server for product images
	mux.Handle("/uploads/",
		http.StripPrefix("/uploads/",
			http.FileServer(http.Dir("uploads"))))

	// Root route for quick check
	mux.HandleFunc("/", handleRoot)

	return mux
}

// handleRoot serves a welcome message at the root path.
func handleRoot(
	writer http.ResponseWriter,
	request *http.Request,
) {
	writer.Header().Set("Content-Type", "application/json")
	writer.Write([]byte(
		`{"message":"Delivery API Gateway","version":"1.0.0"}`,
	))
}

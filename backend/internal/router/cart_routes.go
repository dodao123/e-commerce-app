// Package router configures the API routes for the application.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerCartRoutes registers all cart-related API routes.
// All routes are protected by JWT auth guard.
func registerCartRoutes(
	mux *http.ServeMux,
	cartHandler *handler.CartHandler,
	authGuard func(http.Handler) http.Handler,
) {
	if cartHandler == nil {
		return
	}

	// GET /api/v1/cart — list cart items
	mux.Handle("/api/v1/cart",
		authGuard(http.HandlerFunc(cartHandler.HandleGetCart)),
	)

	// POST /api/v1/cart/items — add item to cart
	mux.Handle("/api/v1/cart/items",
		authGuard(http.HandlerFunc(cartHandler.HandleAddItem)),
	)

	// PUT/DELETE /api/v1/cart/items/{id} — update/remove item
	mux.Handle("/api/v1/cart/items/",
		authGuard(http.HandlerFunc(cartHandler.HandleCartItem)),
	)

	// GET /api/v1/cart/count — badge count
	mux.Handle("/api/v1/cart/count",
		authGuard(http.HandlerFunc(cartHandler.HandleGetCount)),
	)
}

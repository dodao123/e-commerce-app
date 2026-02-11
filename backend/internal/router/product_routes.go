// Package router provides route registration helpers.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerProductRoutes registers product API routes on the mux.
func registerProductRoutes(
	mux *http.ServeMux,
	productHandler *handler.ProductHandler,
	authGuard func(http.Handler) http.Handler,
) {
	if productHandler == nil {
		return
	}

	// Public product routes (no auth required)
	mux.HandleFunc("/api/v1/products/public",
		productHandler.HandleListPublicProducts)
	mux.HandleFunc("/api/v1/shops/{shopId}/products",
		productHandler.HandleListShopProducts)

	// Protected product routes
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
		})))
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
		})))
	mux.Handle("/api/v1/products/{id}/images",
		authGuard(http.HandlerFunc(
			productHandler.HandleUploadImages)))
	mux.Handle("/api/v1/products/{id}/images/delete",
		authGuard(http.HandlerFunc(
			productHandler.HandleDeleteImages)))
}

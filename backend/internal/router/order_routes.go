// Package router provides order route registration.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerOrderRoutes registers order API routes.
func registerOrderRoutes(
	mux *http.ServeMux,
	orderHandler *handler.OrderHandler,
	authGuard func(http.Handler) http.Handler,
) {
	if orderHandler == nil {
		return
	}
	// Buyer: place + list orders
	mux.Handle("/api/v1/orders",
		authGuard(http.HandlerFunc(func(
			w http.ResponseWriter, r *http.Request,
		) {
			switch r.Method {
			case http.MethodPost:
				orderHandler.HandlePlaceOrder(w, r)
			case http.MethodGet:
				orderHandler.HandleListOrders(w, r)
			default:
				http.Error(w, "method not allowed",
					http.StatusMethodNotAllowed)
			}
		})))
	// Order detail
	mux.Handle("/api/v1/orders/{id}",
		authGuard(http.HandlerFunc(
			orderHandler.HandleOrderDetail)))
	// Order status update
	mux.Handle("/api/v1/orders/{id}/status",
		authGuard(http.HandlerFunc(
			orderHandler.HandleUpdateStatus)))
	// Driver: accept delivery
	mux.Handle("/api/v1/orders/{id}/accept-delivery",
		authGuard(http.HandlerFunc(
			orderHandler.HandleAcceptDelivery)))
	// Seller: shop orders
	mux.Handle("/api/v1/shop/orders",
		authGuard(http.HandlerFunc(
			orderHandler.HandleShopOrders)))
	mux.Handle("/api/v1/shop/orders/count",
		authGuard(http.HandlerFunc(
			orderHandler.HandleShopOrderCount)))
	// Driver: list driver's assigned orders
	mux.Handle("/api/v1/driver/orders",
		authGuard(http.HandlerFunc(
			orderHandler.HandleListDriverOrders)))
}

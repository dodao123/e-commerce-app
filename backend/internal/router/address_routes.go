// Package router provides address route registration.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerAddressRoutes registers address API routes.
func registerAddressRoutes(
	mux *http.ServeMux,
	addrHandler *handler.AddressHandler,
	authGuard func(http.Handler) http.Handler,
) {
	if addrHandler == nil {
		return
	}
	mux.Handle("/api/v1/addresses",
		authGuard(http.HandlerFunc(func(
			w http.ResponseWriter, r *http.Request,
		) {
			switch r.Method {
			case http.MethodGet:
				addrHandler.HandleListAddresses(w, r)
			case http.MethodPost:
				addrHandler.HandleCreateAddress(w, r)
			default:
				http.Error(w, "method not allowed",
					http.StatusMethodNotAllowed)
			}
		})))
	mux.Handle("/api/v1/addresses/{id}",
		authGuard(http.HandlerFunc(func(
			w http.ResponseWriter, r *http.Request,
		) {
			switch r.Method {
			case http.MethodDelete:
				addrHandler.HandleDeleteAddress(w, r)
			default:
				http.Error(w, "method not allowed",
					http.StatusMethodNotAllowed)
			}
		})))
}

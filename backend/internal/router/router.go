// Package router configures the API routes for the application.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// NewRouter creates and configures the HTTP router with all API routes.
func NewRouter() *http.ServeMux {
	mux := http.NewServeMux()

	healthHandler := handler.NewHealthHandler()

	// API v1 routes
	mux.HandleFunc("/api/v1/health", healthHandler.Handle)

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
	writer.Write([]byte(`{"message":"Delivery API Gateway","version":"1.0.0"}`))
}

// Package middleware provides HTTP middleware for the API server.
package middleware

import "net/http"

// ApplyCORS wraps an HTTP handler with Cross-Origin Resource Sharing headers.
// This allows the Flutter mobile app to communicate with the API.
func ApplyCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(writer http.ResponseWriter, request *http.Request) {
			writer.Header().Set("Access-Control-Allow-Origin", "*")
			writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

			// Handle preflight requests
			if request.Method == http.MethodOptions {
				writer.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(writer, request)
		},
	)
}

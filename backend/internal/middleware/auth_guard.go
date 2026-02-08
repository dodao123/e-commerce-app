// Package middleware provides HTTP middleware for the API server.
package middleware

import (
	"context"
	"delivery-app/backend/internal/service"
	"net/http"
	"strings"
)

// contextKey is a custom type for context keys to avoid collisions.
type contextKey string

const (
	// UserIDKey is the context key for the authenticated user's ID.
	UserIDKey contextKey = "user_id"

	// UserEmailKey is the context key for the authenticated user's email.
	UserEmailKey contextKey = "user_email"

	// UserRoleKey is the context key for the authenticated user's role.
	UserRoleKey contextKey = "user_role"
)

// AuthGuard creates a middleware that validates JWT tokens.
// Protected routes must include "Authorization: Bearer <token>" header.
func AuthGuard(jwtService *service.JWTService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(
			func(writer http.ResponseWriter, request *http.Request) {
				token := extractBearerToken(request)
				if token == "" {
					http.Error(writer, `{"error":"missing token"}`, http.StatusUnauthorized)
					return
				}

				claims, err := jwtService.ValidateToken(token)
				if err != nil {
					http.Error(writer, `{"error":"invalid token"}`, http.StatusUnauthorized)
					return
				}

				ctx := context.WithValue(request.Context(), UserIDKey, claims.UserID)
				ctx = context.WithValue(ctx, UserEmailKey, claims.Email)
				ctx = context.WithValue(ctx, UserRoleKey, claims.Role)

				next.ServeHTTP(writer, request.WithContext(ctx))
			},
		)
	}
}

// extractBearerToken extracts the JWT token from the Authorization header.
func extractBearerToken(request *http.Request) string {
	authHeader := request.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}

	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || parts[0] != "Bearer" {
		return ""
	}

	return parts[1]
}

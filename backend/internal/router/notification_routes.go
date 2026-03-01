// Package router provides notification route registration.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerNotificationRoutes registers notification API routes.
func registerNotificationRoutes(
	mux *http.ServeMux,
	notifHandler *handler.NotificationHandler,
	authGuard func(http.Handler) http.Handler,
) {
	if notifHandler == nil {
		return
	}
	// List notifications
	mux.Handle("/api/v1/notifications",
		authGuard(http.HandlerFunc(
			notifHandler.HandleList)))
	// Mark read
	mux.Handle("/api/v1/notifications/{id}/read",
		authGuard(http.HandlerFunc(
			notifHandler.HandleMarkRead)))
	// Unread count
	mux.Handle("/api/v1/notifications/unread",
		authGuard(http.HandlerFunc(
			notifHandler.HandleUnreadCount)))
}

// Package handler provides notification HTTP handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"net/http"
)

// NotificationHandler handles notification HTTP requests.
type NotificationHandler struct {
	notifService *service.NotificationService
}

// NewNotificationHandler creates a new handler.
func NewNotificationHandler(
	svc *service.NotificationService,
) *NotificationHandler {
	return &NotificationHandler{notifService: svc}
}

// HandleList handles GET /api/v1/notifications.
func (h *NotificationHandler) HandleList(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	role := r.URL.Query().Get("role")
	if role == "" {
		role = "buyer"
	}
	list, err := h.notifService.ListByUser(userID, role)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to list notifications")
		return
	}
	if list == nil {
		list = []model.Notification{}
	}
	WriteJSON(w, http.StatusOK, list)
}

// HandleMarkRead handles PUT /notifications/{id}/read.
func (h *NotificationHandler) HandleMarkRead(
	w http.ResponseWriter, r *http.Request,
) {
	notifID := r.PathValue("id")
	if err := h.notifService.MarkRead(notifID); err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to mark read")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]string{"status": "read"})
}

// HandleUnreadCount handles GET /notifications/unread.
func (h *NotificationHandler) HandleUnreadCount(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	role := r.URL.Query().Get("role")
	if role == "" {
		role = "buyer"
	}
	count, err := h.notifService.CountUnread(userID, role)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to count")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]int{"count": count})
}

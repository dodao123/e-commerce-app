package handler

import (
	"delivery-app/backend/internal/middleware"
	"net/http"
	"strconv"
)

// HandleListMessages handles GET /api/v1/chat/rooms/{id}/messages.
func (h *ChatHandler) HandleListMessages(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		WriteError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	roomID := r.PathValue("id")
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	if limit <= 0 {
		limit = 50
	}

	messages, err := h.chatService.ListMessages(r.Context(), roomID, limit, offset)
	if err != nil {
		WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}
	WriteJSON(w, http.StatusOK, messages)
}

// HandleMarkAsRead handles POST /api/v1/chat/rooms/{id}/read.
func (h *ChatHandler) HandleMarkAsRead(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		WriteError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	roomID := r.PathValue("id")
	userID, ok := r.Context().Value(middleware.UserIDKey).(string)
	if !ok {
		WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	if err := h.chatService.MarkAsRead(r.Context(), roomID, userID); err != nil {
		WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}
	WriteJSON(w, http.StatusOK, map[string]bool{"success": true})
}

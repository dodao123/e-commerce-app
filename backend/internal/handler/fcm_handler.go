// Package handler provides FCM token HTTP handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/repository"
	"net/http"
)

// FcmHandler handles FCM token registration.
type FcmHandler struct {
	tokenRepo *repository.PostgresFcmTokenRepository
}

// NewFcmHandler creates a new FcmHandler.
func NewFcmHandler(
	tokenRepo *repository.PostgresFcmTokenRepository,
) *FcmHandler {
	return &FcmHandler{tokenRepo: tokenRepo}
}

// HandleRegisterToken handles POST /api/v1/fcm/token.
// Flutter calls this after login to save the device token.
func (h *FcmHandler) HandleRegisterToken(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	var req struct {
		Token string `json:"token"`
	}
	if err := ReadJSON(r, &req); err != nil || req.Token == "" {
		WriteError(w, http.StatusBadRequest, "token required")
		return
	}
	if err := h.tokenRepo.Upsert(userID, req.Token); err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to save token")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]string{"message": "token registered"})
}

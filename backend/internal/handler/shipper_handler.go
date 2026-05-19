package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"net/http"
	"log"

	"github.com/go-playground/validator/v10"
)

// ShipperHandler handles API endpoints for shipper profiles.
type ShipperHandler struct {
	svc *service.ShipperService
}

// NewShipperHandler creates a new handler.
func NewShipperHandler(svc *service.ShipperService) *ShipperHandler {
	return &ShipperHandler{svc: svc}
}

// HandleGetProfile returns the current logged-in driver's profile.
func (h *ShipperHandler) HandleGetProfile(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(middleware.UserIDKey).(string)
	profile, err := h.svc.GetProfile(userID)
	if err != nil {
		log.Println("GetProfile ERROR:", err)
		WriteError(w, http.StatusInternalServerError, "failed to get profile")
		return
	}
	if profile == nil {
		log.Println("GetProfile NOT FOUND for user:", userID)
		WriteError(w, http.StatusNotFound, "profile not found")
		return
	}
	log.Println("GetProfile SUCCESS:", profile)
	WriteJSON(w, http.StatusOK, profile)
}

// HandleUpdateProfile creates or updates the driver's profile.
func (h *ShipperHandler) HandleUpdateProfile(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(middleware.UserIDKey).(string)
	var req model.ShipperProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Println("UpdateProfile decode ERROR:", err)
		WriteError(w, http.StatusBadRequest, "invalid payload")
		return
	}

	validate := validator.New()
	if err := validate.Struct(&req); err != nil {
		log.Println("UpdateProfile validate ERROR:", err)
		WriteError(w, http.StatusBadRequest, err.Error())
		return
	}

	profile, err := h.svc.SaveProfile(userID, req)
	if err != nil {
		log.Println("UpdateProfile save ERROR:", err)
		WriteError(w, http.StatusInternalServerError, "failed to save profile")
		return
	}
	log.Println("UpdateProfile SUCCESS:", profile)
	WriteJSON(w, http.StatusOK, profile)
}

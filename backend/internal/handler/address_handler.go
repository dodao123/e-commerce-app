// Package handler provides address HTTP handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"log"
	"net/http"
)

// AddressHandler handles address CRUD requests.
type AddressHandler struct {
	addressService *service.AddressService
}

// NewAddressHandler creates a new address handler.
func NewAddressHandler(
	svc *service.AddressService,
) *AddressHandler {
	return &AddressHandler{addressService: svc}
}

// HandleListAddresses handles GET /api/v1/addresses.
func (h *AddressHandler) HandleListAddresses(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	list, err := h.addressService.ListByUser(userID)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to list addresses")
		return
	}
	if list == nil {
		list = []model.DeliveryAddress{}
	}
	WriteJSON(w, http.StatusOK, list)
}

// HandleCreateAddress handles POST /api/v1/addresses.
func (h *AddressHandler) HandleCreateAddress(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	var addr model.DeliveryAddress
	if err := json.NewDecoder(r.Body).Decode(&addr); err != nil {
		WriteError(w, http.StatusBadRequest,
			"invalid body")
		return
	}
	log.Printf("[AddressHandler] Creating address: %+v", addr)
	addr.UserID = userID
	created, err := h.addressService.Create(addr)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"create failed")
		return
	}
	WriteJSON(w, http.StatusCreated, created)
}

// HandleDeleteAddress handles DELETE /api/v1/addresses/{id}.
func (h *AddressHandler) HandleDeleteAddress(
	w http.ResponseWriter, r *http.Request,
) {
	addrID := r.PathValue("id")
	if err := h.addressService.Delete(addrID); err != nil {
		WriteError(w, http.StatusInternalServerError,
			"delete failed")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]string{"status": "deleted"})
}

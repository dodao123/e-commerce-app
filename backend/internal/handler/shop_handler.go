// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"net/http"
)

// ShopHandler handles HTTP requests for shop operations.
type ShopHandler struct {
	shopService *service.ShopService
}

// NewShopHandler creates a new shop handler instance.
func NewShopHandler(shopService *service.ShopService) *ShopHandler {
	return &ShopHandler{shopService: shopService}
}

// HandleCreateShop handles POST /api/v1/shops
// Creates a new shop for the authenticated seller.
func (handler *ShopHandler) HandleCreateShop(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	// Get seller ID from context (set by auth middleware)
	sellerID, ok := request.Context().Value(middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	// Parse request body
	var createRequest model.CreateShopRequest
	if err := json.NewDecoder(request.Body).Decode(&createRequest); err != nil {
		WriteError(writer, http.StatusBadRequest, "invalid request body")
		return
	}

	// Create shop
	shop, err := handler.shopService.CreateShop(
		request.Context(), sellerID, &createRequest,
	)
	if err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	WriteJSON(writer, http.StatusCreated, shop)
}

// HandleGetMyShop handles GET /api/v1/shops/me
// Retrieves the shop of the authenticated seller.
func (handler *ShopHandler) HandleGetMyShop(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	// Get seller ID from context
	sellerID, ok := request.Context().Value(middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	// Get shop
	shop, err := handler.shopService.GetShopBySellerID(
		request.Context(), sellerID,
	)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError, err.Error())
		return
	}

	if shop == nil {
		WriteError(writer, http.StatusNotFound, "shop not found")
		return
	}

	WriteJSON(writer, http.StatusOK, shop)
}

// HandleUpdateShop handles PUT /api/v1/shops/:id
// Updates shop information for the authenticated seller.
func (handler *ShopHandler) HandleUpdateShop(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPut {
		WriteError(writer, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	// Get seller ID from context
	sellerID, ok := request.Context().Value(middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	// Get shop ID from URL path
	shopID := request.PathValue("id")
	if shopID == "" {
		WriteError(writer, http.StatusBadRequest, "shop ID required")
		return
	}

	// Parse request body
	var updateRequest model.UpdateShopRequest
	if err := json.NewDecoder(request.Body).Decode(&updateRequest); err != nil {
		WriteError(writer, http.StatusBadRequest, "invalid request body")
		return
	}

	// Update shop
	shop, err := handler.shopService.UpdateShop(
		request.Context(), shopID, sellerID, &updateRequest,
	)
	if err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, shop)
}

// HandleGetPublicShop handles GET /api/v1/shops/{id}/public
func (handler *ShopHandler) HandleGetPublicShop(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	shopID := request.PathValue("id")
	if shopID == "" {
		WriteError(writer, http.StatusBadRequest, "shop ID required")
		return
	}

	shop, err := handler.shopService.GetPublicShopByID(request.Context(), shopID)
	if err != nil {
		WriteError(writer, http.StatusNotFound, "shop not found")
		return
	}

	WriteJSON(writer, http.StatusOK, shop)
}

// HandleListPublicShops handles GET /api/v1/shops/public
func (handler *ShopHandler) HandleListPublicShops(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	limit := queryInt(request, "limit", 50)
	offset := queryInt(request, "offset", 0)

	shops, err := handler.shopService.ListPublicShops(request.Context(), limit, offset)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, shops)
}

// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"encoding/json"
	"log"
	"net/http"
)

// deleteImagesRequest is the payload for deleting images.
type deleteImagesRequest struct {
	// Images is the list of image paths to delete.
	Images []string `json:"images"`
}

// HandleDeleteImages handles POST /api/v1/products/{id}/images/delete.
func (handler *ProductHandler) HandleDeleteImages(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	sellerID, ok := request.Context().Value(
		middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized,
			"unauthorized")
		return
	}

	productID := request.PathValue("id")
	if productID == "" {
		WriteError(writer, http.StatusBadRequest,
			"product ID required")
		return
	}

	var deleteRequest deleteImagesRequest
	if err := json.NewDecoder(request.Body).Decode(
		&deleteRequest); err != nil {
		WriteError(writer, http.StatusBadRequest,
			"invalid request body")
		return
	}

	product, err := handler.productService.GetProduct(
		request.Context(), productID)
	if err != nil {
		WriteError(writer, http.StatusNotFound, err.Error())
		return
	}

	// Verify ownership
	shop, shopErr := handler.productService.GetShopBySellerID(
		request.Context(), sellerID)
	if shopErr != nil || shop == nil || shop.ID != product.ShopID {
		WriteError(writer, http.StatusForbidden,
			"unauthorized: not product owner")
		return
	}

	// Delete image files and update DB
	remaining, delErr := handler.productService.DeleteProductImages(
		shop.ID, productID,
		deleteRequest.Images, product.Images)
	if delErr != nil {
		WriteError(writer, http.StatusInternalServerError,
			delErr.Error())
		return
	}

	product.Images = remaining
	if err := handler.productService.UpdateProductImages(
		request.Context(), product); err != nil {
		log.Printf("❌ Update images DB: %v", err)
		WriteError(writer, http.StatusInternalServerError,
			"failed to update images")
		return
	}

	WriteJSON(writer, http.StatusOK,
		map[string]any{"remaining": remaining})
}

// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"encoding/json"
	"net/http"
)

// HandleUpdateProduct handles PUT /api/v1/products/{id}.
func (handler *ProductHandler) HandleUpdateProduct(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPut {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	sellerID, ok := request.Context().Value(
		middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	productID := request.PathValue("id")
	if productID == "" {
		WriteError(writer, http.StatusBadRequest,
			"product ID required")
		return
	}

	var updateReq model.UpdateProductRequest
	if err := json.NewDecoder(request.Body).Decode(
		&updateReq); err != nil {
		WriteError(writer, http.StatusBadRequest,
			"invalid request body")
		return
	}

	product, err := handler.productService.UpdateProduct(
		request.Context(), sellerID, productID, &updateReq)
	if err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, product)
}

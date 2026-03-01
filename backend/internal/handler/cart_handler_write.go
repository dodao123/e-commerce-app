// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"encoding/json"
	"net/http"
	"strings"
)

// addItemRequest is the JSON body for adding a cart item.
type addItemRequest struct {
	ProductID string `json:"product_id"`
	Quantity  int    `json:"quantity"`
}

// updateQuantityRequest is the JSON body for updating quantity.
type updateQuantityRequest struct {
	Quantity int `json:"quantity"`
}

// HandleAddItem adds a product to the buyer's cart.
func (handler *CartHandler) HandleAddItem(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		http.Error(writer, `{"error":"method not allowed"}`,
			http.StatusMethodNotAllowed)
		return
	}

	userID := request.Context().Value(
		middleware.UserIDKey).(string)

	var body addItemRequest
	if err := json.NewDecoder(request.Body).Decode(&body); err != nil {
		http.Error(writer, `{"error":"invalid body"}`,
			http.StatusBadRequest)
		return
	}

	item, err := handler.cartService.AddItem(
		request.Context(), userID, body.ProductID, body.Quantity)
	if err != nil {
		writeCartError(writer, err)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.WriteHeader(http.StatusCreated)
	json.NewEncoder(writer).Encode(item)
}

// HandleCartItem handles PUT (update qty) and DELETE (remove).
// Route: /api/v1/cart/items/{id}
func (handler *CartHandler) HandleCartItem(
	writer http.ResponseWriter,
	request *http.Request,
) {
	userID := request.Context().Value(
		middleware.UserIDKey).(string)

	itemID := extractCartItemID(request.URL.Path)
	if itemID == "" {
		http.Error(writer, `{"error":"missing item id"}`,
			http.StatusBadRequest)
		return
	}

	switch request.Method {
	case http.MethodPut:
		handler.updateQuantity(writer, request, itemID, userID)
	case http.MethodDelete:
		handler.removeItem(writer, request, itemID, userID)
	default:
		http.Error(writer, `{"error":"method not allowed"}`,
			http.StatusMethodNotAllowed)
	}
}

// extractCartItemID parses item ID from URL path.
func extractCartItemID(path string) string {
	parts := strings.Split(path, "/")
	if len(parts) < 2 {
		return ""
	}
	return parts[len(parts)-1]
}

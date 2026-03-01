// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"fmt"
	"net/http"
)

// CartHandler handles HTTP requests for cart operations.
type CartHandler struct {
	cartService *service.CartService
}

// NewCartHandler creates a new cart handler instance.
func NewCartHandler(
	cartService *service.CartService,
) *CartHandler {
	return &CartHandler{cartService: cartService}
}

// HandleGetCart returns the buyer's cart items with product/shop info.
func (handler *CartHandler) HandleGetCart(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		http.Error(writer, `{"error":"method not allowed"}`,
			http.StatusMethodNotAllowed)
		return
	}

	userID := request.Context().Value(
		middleware.UserIDKey).(string)

	items, err := handler.cartService.GetCart(
		request.Context(), userID)
	if err != nil {
		fmt.Printf("❌ Cart query error: %v\n", err)
		http.Error(writer, `{"error":"failed to get cart"}`,
			http.StatusInternalServerError)
		return
	}

	if items == nil {
		writer.Header().Set("Content-Type", "application/json")
		writer.Write([]byte("[]"))
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(items)
}

// HandleGetCount returns the total item count for badge display.
func (handler *CartHandler) HandleGetCount(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		http.Error(writer, `{"error":"method not allowed"}`,
			http.StatusMethodNotAllowed)
		return
	}

	userID := request.Context().Value(
		middleware.UserIDKey).(string)

	count, err := handler.cartService.GetCount(
		request.Context(), userID)
	if err != nil {
		http.Error(writer, `{"error":"failed to get count"}`,
			http.StatusInternalServerError)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(map[string]int{
		"count": count,
	})
}

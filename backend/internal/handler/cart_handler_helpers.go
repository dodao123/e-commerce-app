// Package handler provides HTTP request handlers for the API.
package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

// updateQuantity handles PUT to change item quantity.
func (handler *CartHandler) updateQuantity(
	writer http.ResponseWriter,
	request *http.Request,
	itemID string,
	userID string,
) {
	var body updateQuantityRequest
	if err := json.NewDecoder(request.Body).Decode(&body); err != nil {
		http.Error(writer, `{"error":"invalid body"}`,
			http.StatusBadRequest)
		return
	}

	if err := handler.cartService.UpdateQuantity(
		request.Context(), itemID, userID, body.Quantity,
	); err != nil {
		writeCartError(writer, err)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(map[string]string{
		"status": "updated",
	})
}

// removeItem handles DELETE to remove a cart item.
func (handler *CartHandler) removeItem(
	writer http.ResponseWriter,
	request *http.Request,
	itemID string,
	userID string,
) {
	if err := handler.cartService.RemoveItem(
		request.Context(), itemID, userID,
	); err != nil {
		http.Error(writer, `{"error":"failed to remove"}`,
			http.StatusInternalServerError)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(map[string]string{
		"status": "removed",
	})
}

// writeCartError writes a formatted error response.
func writeCartError(writer http.ResponseWriter, err error) {
	message := err.Error()
	status := http.StatusInternalServerError

	if strings.Contains(message, "not found") {
		status = http.StatusNotFound
	} else if strings.Contains(message, "insufficient") ||
		strings.Contains(message, "must be positive") {
		status = http.StatusBadRequest
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.WriteHeader(status)
	fmt.Fprintf(writer, `{"error":"%s"}`, message)
}

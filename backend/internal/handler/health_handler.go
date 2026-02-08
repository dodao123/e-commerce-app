// Package handler provides HTTP request handlers for the API.
package handler

import (
	"encoding/json"
	"net/http"
	"time"
)

// HealthResponse represents the JSON response for the health check endpoint.
type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
	Service   string `json:"service"`
	Version   string `json:"version"`
}

// HealthHandler handles health check requests.
type HealthHandler struct{}

// NewHealthHandler creates a new HealthHandler instance.
func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

// Handle processes the health check request and returns server status.
func (h *HealthHandler) Handle(
	writer http.ResponseWriter,
	request *http.Request,
) {
	response := HealthResponse{
		Status:    "ok",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Service:   "delivery-api",
		Version:   "1.0.0",
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.WriteHeader(http.StatusOK)

	if err := json.NewEncoder(writer).Encode(response); err != nil {
		http.Error(writer, "Internal Server Error", http.StatusInternalServerError)
	}
}

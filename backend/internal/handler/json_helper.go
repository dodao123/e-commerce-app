// Package handler provides HTTP request handlers for the API.
package handler

import (
	"encoding/json"
	"net/http"
)

// WriteJSON sends a JSON response with the given status code and data.
func WriteJSON(
	writer http.ResponseWriter,
	statusCode int,
	data interface{},
) {
	writer.Header().Set("Content-Type", "application/json")
	writer.WriteHeader(statusCode)
	json.NewEncoder(writer).Encode(data)
}

// WriteError sends a JSON error response with a message.
func WriteError(
	writer http.ResponseWriter,
	statusCode int,
	message string,
) {
	WriteJSON(writer, statusCode, map[string]string{
		"error": message,
	})
}

// ReadJSON decodes the request body into the target struct.
func ReadJSON(request *http.Request, target interface{}) error {
	defer request.Body.Close()
	return json.NewDecoder(request.Body).Decode(target)
}

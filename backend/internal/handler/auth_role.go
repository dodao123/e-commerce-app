// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"net/http"
)

// validRoles is the set of allowed roles for selection.
var validRoles = map[string]model.UserRole{
	"buyer":  model.RoleBuyer,
	"seller": model.RoleSeller,
	"driver": model.RoleDriver,
}

// HandleUpdateRole processes role selection requests.
// Requires JWT authentication (AuthGuard middleware).
// Accepts POST with {"role": "buyer|seller|driver"} body.
func (handler *AuthHandler) HandleUpdateRole(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "POST only")
		return
	}

	// Get user ID from JWT context (set by AuthGuard)
	userID, ok := request.Context().Value(
		middleware.UserIDKey,
	).(string)
	if !ok || userID == "" {
		WriteError(writer, http.StatusUnauthorized, "Invalid token")
		return
	}

	var roleRequest model.RoleUpdateRequest
	if err := ReadJSON(request, &roleRequest); err != nil {
		WriteError(writer, http.StatusBadRequest, "Invalid request body")
		return
	}

	role, isValid := validRoles[roleRequest.Role]
	if !isValid {
		WriteError(writer, http.StatusBadRequest,
			"Invalid role. Must be: buyer, seller, or driver")
		return
	}

	if err := handler.userRepository.UpdateRole(userID, role); err != nil {
		WriteError(writer, http.StatusInternalServerError,
			"Failed to update role")
		return
	}

	WriteJSON(writer, http.StatusOK, model.RoleUpdateResponse{
		Message: "Role updated successfully",
		Role:    string(role),
	})
}

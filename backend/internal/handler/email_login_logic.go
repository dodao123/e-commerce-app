// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"log"
	"net/http"
)

// HandleLogin authenticates a user with email and password.
func (handler *EmailAuthHandler) HandleLogin(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "POST only")
		return
	}

	var loginReq model.EmailLoginRequest
	if err := ReadJSON(request, &loginReq); err != nil {
		WriteError(writer, http.StatusBadRequest, "Invalid request body")
		return
	}

	if loginReq.Email == "" || loginReq.Password == "" {
		WriteError(writer, http.StatusBadRequest, "Email and password required")
		return
	}

	handler.processLogin(writer, &loginReq)
}

// processLogin handles the core login logic.
func (handler *EmailAuthHandler) processLogin(
	writer http.ResponseWriter,
	req *model.EmailLoginRequest,
) {
	user, err := handler.userRepository.FindByEmailWithPassword(req.Email)
	if err != nil {
		log.Printf("❌ DB error in login: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Server error")
		return
	}

	if user == nil {
		WriteError(writer, http.StatusUnauthorized, "Invalid email or password")
		return
	}

	if user.PasswordHash == "" {
		WriteError(writer, http.StatusUnauthorized,
			"Account uses social login. Please use Google or Facebook")
		return
	}

	if !handler.bcryptService.ComparePassword(user.PasswordHash, req.Password) {
		WriteError(writer, http.StatusUnauthorized, "Invalid email or password")
		return
	}

	// Update last login
	_ = handler.userRepository.UpdateLastLogin(user.ID)

	// Generate JWT
	token, err := handler.jwtService.GenerateToken(
		user.ID, user.Email, string(user.Role),
	)
	if err != nil {
		log.Printf("❌ Token error: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Server error")
		return
	}

	handler.writeAuthResponse(writer, token, user)
}

// writeAuthResponse sends the standard auth JSON response.
func (handler *EmailAuthHandler) writeAuthResponse(
	writer http.ResponseWriter,
	token string,
	user *model.User,
) {
	WriteJSON(writer, http.StatusOK, model.AuthResponse{
		AccessToken: token,
		TokenType:   "Bearer",
		ExpiresIn:   handler.jwtService.ExpirySeconds(),
		User: &model.UserPublicProfile{
			ID:       user.ID,
			Email:    user.Email,
			FullName: user.FullName,
			Role:     string(user.Role),
		},
	})
}

// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"fmt"
	"log"
	"net/http"
	"regexp"
)

// emailRegex is a basic email format validator.
var emailRegex = regexp.MustCompile(
	`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`,
)

// validateRegisterRequest checks required fields and formats.
func validateRegisterRequest(req *model.EmailRegisterRequest) error {
	if req.Email == "" {
		return fmt.Errorf("email is required")
	}
	if !emailRegex.MatchString(req.Email) {
		return fmt.Errorf("invalid email format")
	}
	if len(req.Password) < 6 {
		return fmt.Errorf("password must be at least 6 characters")
	}
	if req.FullName == "" {
		return fmt.Errorf("full_name is required")
	}
	return nil
}

// processRegistration handles the core registration logic.
func (handler *EmailAuthHandler) processRegistration(
	writer http.ResponseWriter,
	req *model.EmailRegisterRequest,
) {
	// Check if email already exists
	existing, err := handler.userRepository.FindByEmail(req.Email)
	if err != nil {
		log.Printf("❌ DB error in register: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Server error")
		return
	}
	if existing != nil {
		WriteError(writer, http.StatusConflict, "Email already registered")
		return
	}

	// Hash password
	hash, err := handler.bcryptService.HashPassword(req.Password)
	if err != nil {
		log.Printf("❌ Hash error: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Server error")
		return
	}

	// Create user with password hash
	user := &model.User{
		Email:        req.Email,
		FullName:     req.FullName,
		PasswordHash: hash,
		Role:         model.RoleBuyer,
	}

	created, err := handler.userRepository.CreateWithPassword(user)
	if err != nil {
		log.Printf("❌ Create user error: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Registration failed")
		return
	}

	// Generate JWT token
	token, err := handler.jwtService.GenerateToken(
		created.ID, created.Email, string(created.Role),
	)
	if err != nil {
		log.Printf("❌ Token error: %v", err)
		WriteError(writer, http.StatusInternalServerError, "Server error")
		return
	}

	handler.writeAuthResponse(writer, token, created)
}

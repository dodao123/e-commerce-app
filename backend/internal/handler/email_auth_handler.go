// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/service"
	"net/http"
)

// EmailAuthHandler handles email/password registration and login.
type EmailAuthHandler struct {
	userRepository repository.UserRepository
	jwtService     *service.JWTService
	bcryptService  *service.BcryptService
}

// NewEmailAuthHandler creates a new EmailAuthHandler.
func NewEmailAuthHandler(
	userRepo repository.UserRepository,
	jwtService *service.JWTService,
	bcryptService *service.BcryptService,
) *EmailAuthHandler {
	return &EmailAuthHandler{
		userRepository: userRepo,
		jwtService:     jwtService,
		bcryptService:  bcryptService,
	}
}

// HandleRegister creates a new user with email and hashed password.
func (handler *EmailAuthHandler) HandleRegister(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "POST only")
		return
	}

	var registerReq model.EmailRegisterRequest
	if err := ReadJSON(request, &registerReq); err != nil {
		WriteError(writer, http.StatusBadRequest, "Invalid request body")
		return
	}

	if err := validateRegisterRequest(&registerReq); err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	handler.processRegistration(writer, &registerReq)
}

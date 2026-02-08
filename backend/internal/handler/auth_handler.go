// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/service"
	"net/http"
)

// AuthHandler handles authentication requests (Google / Facebook login).
type AuthHandler struct {
	userRepository     repository.UserRepository
	authProviderRepo   repository.AuthProviderRepository
	jwtService         *service.JWTService
	googleVerifier     *service.GoogleVerifier
	facebookVerifier   *service.FacebookVerifier
}

// NewAuthHandler creates a new AuthHandler with all dependencies.
func NewAuthHandler(
	userRepo repository.UserRepository,
	authProviderRepo repository.AuthProviderRepository,
	jwtService *service.JWTService,
	googleVerifier *service.GoogleVerifier,
	facebookVerifier *service.FacebookVerifier,
) *AuthHandler {
	return &AuthHandler{
		userRepository:   userRepo,
		authProviderRepo: authProviderRepo,
		jwtService:       jwtService,
		googleVerifier:   googleVerifier,
		facebookVerifier: facebookVerifier,
	}
}

// HandleGoogleLogin processes Google Sign-In requests.
// Accepts POST with {"id_token": "..."} body.
func (handler *AuthHandler) HandleGoogleLogin(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "POST only")
		return
	}

	var loginRequest model.GoogleLoginRequest
	if err := ReadJSON(request, &loginRequest); err != nil {
		WriteError(writer, http.StatusBadRequest, "Invalid request body")
		return
	}

	if loginRequest.IDToken == "" {
		WriteError(writer, http.StatusBadRequest, "id_token is required")
		return
	}

	profile, err := handler.googleVerifier.VerifyIDToken(loginRequest.IDToken)
	if err != nil {
		WriteError(writer, http.StatusUnauthorized, "Invalid Google token: "+err.Error())
		return
	}

	handler.handleSocialLogin(writer, profile, model.ProviderGoogle)
}

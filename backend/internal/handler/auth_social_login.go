// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"log"
	"net/http"
)

// handleSocialLogin is the shared logic for both Google and Facebook login.
// It finds or creates a user, links the auth provider, and returns a JWT.
func (handler *AuthHandler) handleSocialLogin(
	writer http.ResponseWriter,
	profile *service.SocialProfile,
	provider model.AuthProvider,
) {
	// 1. Check if this provider account is already linked
	authProvider, err := handler.authProviderRepo.FindByProvider(
		provider, profile.ProviderID,
	)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError, "Database error")
		log.Printf("❌ FindByProvider error: %v", err)
		return
	}

	var user *model.User

	if authProvider != nil {
		// Existing provider link → find the user
		user, err = handler.userRepository.FindByID(authProvider.UserID)
		if err != nil || user == nil {
			WriteError(writer, http.StatusInternalServerError, "User not found")
			return
		}
		// Update profile with latest data from provider
		handler.updateUserProfile(user, profile)
	} else {
		// New provider → check if email already exists
		user, err = handler.findOrCreateUser(profile, provider)
		if err != nil {
			WriteError(writer, http.StatusInternalServerError, err.Error())
			return
		}
	}

	// Update last login timestamp
	handler.userRepository.UpdateLastLogin(user.ID)

	// Generate JWT token
	token, err := handler.jwtService.GenerateToken(
		user.ID, user.Email, string(user.Role),
	)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError, "Token generation failed")
		return
	}

	WriteJSON(writer, http.StatusOK, model.AuthResponse{
		AccessToken: token,
		TokenType:   "Bearer",
		ExpiresIn:   handler.jwtService.ExpirySeconds(),
		User: &model.UserPublicProfile{
			ID:        user.ID,
			Email:     user.Email,
			FullName:  user.FullName,
			AvatarURL: user.AvatarURL,
			Role:      string(user.Role),
		},
	})
}

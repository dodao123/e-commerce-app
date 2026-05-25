// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"fmt"
	"log"
)

// findOrCreateUser finds an existing user by email or creates a new one,
// then links the auth provider to the user account.
func (handler *AuthHandler) findOrCreateUser(
	profile *service.SocialProfile,
	provider model.AuthProvider,
) (*model.User, error) {
	// Check if a user with this email already exists
	user, err := handler.userRepository.FindByEmail(profile.Email)
	if err != nil {
		return nil, fmt.Errorf("database error: %w", err)
	}

	if user == nil {
		// Create new user
		user = &model.User{
			Email:         profile.Email,
			EmailVerified: profile.EmailVerified,
			FullName:      profile.FullName,
			AvatarURL:     profile.AvatarURL,
			Locale:        profile.Locale,
			Role:          model.RoleUnselected,
		}

		user, err = handler.userRepository.Create(user)
		if err != nil {
			return nil, fmt.Errorf("failed to create user: %w", err)
		}

		log.Printf("👤 New user created: %s (%s)", user.Email, user.ID)
	}

	// Link the new auth provider to this user
	_, err = handler.authProviderRepo.Create(&model.UserAuthProvider{
		UserID:     user.ID,
		Provider:   provider,
		ProviderID: profile.ProviderID,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to link provider: %w", err)
	}

	log.Printf("🔗 Linked %s provider to user %s", provider, user.ID)

	return user, nil
}

// updateUserProfile updates the user's profile with the latest OAuth data.
func (handler *AuthHandler) updateUserProfile(
	user *model.User,
	profile *service.SocialProfile,
) {
	user.FullName = profile.FullName
	user.AvatarURL = profile.AvatarURL
	user.EmailVerified = profile.EmailVerified

	if profile.Locale != "" {
		user.Locale = profile.Locale
	}

	if err := handler.userRepository.UpdateProfile(user); err != nil {
		log.Printf("⚠️ Failed to update profile for user %s: %v", user.ID, err)
	}
}

// Package repository provides database access for domain entities.
package repository

import (
	"delivery-app/backend/internal/model"
)

// UserRepository defines the contract for user data access.
type UserRepository interface {
	// FindByEmail finds a user by their email address.
	FindByEmail(email string) (*model.User, error)

	// FindByID finds a user by their UUID.
	FindByID(id string) (*model.User, error)

	// Create inserts a new user and returns it with generated ID.
	Create(user *model.User) (*model.User, error)

	// UpdateProfile updates the user's mutable profile fields.
	UpdateProfile(user *model.User) error

	// UpdateLastLogin sets the last login timestamp to now.
	UpdateLastLogin(userID string) error

	// UpdateRole sets the user's role.
	UpdateRole(userID string, role model.UserRole) error

	// CreateWithPassword inserts a new user with password hash.
	CreateWithPassword(user *model.User) (*model.User, error)

	// FindByEmailWithPassword finds user including password hash.
	FindByEmailWithPassword(email string) (*model.User, error)
}

// AuthProviderRepository defines the contract for auth provider data access.
type AuthProviderRepository interface {
	// FindByProvider finds a provider link by provider name and provider ID.
	FindByProvider(provider model.AuthProvider, providerID string) (*model.UserAuthProvider, error)

	// Create links an OAuth provider to a user.
	Create(authProvider *model.UserAuthProvider) (*model.UserAuthProvider, error)

	// FindByUserID returns all auth providers linked to a user.
	FindByUserID(userID string) ([]model.UserAuthProvider, error)
}

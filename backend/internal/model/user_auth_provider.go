// Package model defines data structures for database entities.
package model

import "time"

// AuthProvider represents the social login provider type.
type AuthProvider string

const (
	// ProviderGoogle represents Google authentication.
	ProviderGoogle AuthProvider = "google"

	// ProviderFacebook represents Facebook authentication.
	ProviderFacebook AuthProvider = "facebook"
)

// UserAuthProvider links a user account to an OAuth provider.
// A single user can have multiple providers (Google + Facebook + Apple).
type UserAuthProvider struct {
	// ID is the primary key (UUID).
	ID string `json:"id"`

	// UserID references the users table (foreign key).
	UserID string `json:"user_id"`

	// Provider is the OAuth source (google / facebook).
	Provider AuthProvider `json:"provider"`

	// ProviderID is the unique user ID from the OAuth provider.
	ProviderID string `json:"provider_id"`

	// CreatedAt is when this provider link was created.
	CreatedAt time.Time `json:"created_at"`
}

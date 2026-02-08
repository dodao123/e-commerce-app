// Package service provides business logic for the application.
package service

// SocialProfile represents the unified user profile from any OAuth provider.
// Both Google and Facebook verifiers return this common structure.
type SocialProfile struct {
	// ProviderID is the unique user ID from the OAuth provider.
	ProviderID string

	// Email is the user's email address.
	Email string

	// EmailVerified indicates if the provider has verified the email.
	EmailVerified bool

	// FullName is the user's display name.
	FullName string

	// AvatarURL is the profile picture URL.
	AvatarURL string

	// Locale is the user's language preference (e.g. "vi").
	Locale string
}

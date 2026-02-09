// Package model defines data structures for database entities.
package model

// EmailRegisterRequest represents the request body for email registration.
type EmailRegisterRequest struct {
	// Email is the user's email address.
	Email string `json:"email"`

	// Password is the plaintext password (will be hashed server-side).
	Password string `json:"password"`

	// FullName is the user's display name.
	FullName string `json:"full_name"`
}

// EmailLoginRequest represents the request body for email login.
type EmailLoginRequest struct {
	// Email is the user's email address.
	Email string `json:"email"`

	// Password is the plaintext password to verify.
	Password string `json:"password"`
}

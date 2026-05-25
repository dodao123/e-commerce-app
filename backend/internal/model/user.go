// Package model defines data structures for database entities.
package model

import "time"

// UserRole represents the role of a user in the system.
type UserRole string

const (
	// RoleBuyer is a customer who purchases products.
	RoleBuyer UserRole = "buyer"

	// RoleSeller is a merchant who sells products.
	RoleSeller UserRole = "seller"

	// RoleDriver is a delivery driver.
	RoleDriver UserRole = "driver"

	// RoleAdmin is a system administrator.
	RoleAdmin UserRole = "admin"

	// RoleUnselected represents a user who has not selected a role yet.
	RoleUnselected UserRole = "unselected"
)

// User represents a registered user in the system.
// One user can have multiple auth providers (Google, Facebook, etc.).
type User struct {
	// ID is the primary key (UUID).
	ID string `json:"id"`

	// Email is the user's primary email address (unique).
	Email string `json:"email"`

	// EmailVerified indicates if the email has been verified.
	EmailVerified bool `json:"email_verified"`

	// FullName is the user's display name.
	FullName string `json:"full_name"`

	// AvatarURL is the profile picture URL.
	AvatarURL string `json:"avatar_url,omitempty"`

	// Locale is the user's language preference (e.g. "vi").
	Locale string `json:"locale,omitempty"`

	// Role is the user's role in the platform.
	Role UserRole `json:"role"`

	// PasswordHash stores the bcrypt-hashed password (never exposed in JSON).
	PasswordHash string `json:"-"`

	// IsActive indicates whether the account is enabled.
	IsActive bool `json:"is_active"`

	// LastLoginAt is the timestamp of the most recent login.
	LastLoginAt *time.Time `json:"last_login_at,omitempty"`

	// CreatedAt is when the user was first registered.
	CreatedAt time.Time `json:"created_at"`

	// UpdatedAt is when the profile was last modified.
	UpdatedAt time.Time `json:"updated_at"`
}

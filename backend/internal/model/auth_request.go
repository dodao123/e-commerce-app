// Package model defines data structures for database entities.
package model

// GoogleLoginRequest represents the request body for Google login.
// The Flutter app sends the ID token obtained from Google Sign-In SDK.
type GoogleLoginRequest struct {
	// IDToken is the JWT token from Google Sign-In.
	IDToken string `json:"id_token"`
}

// FacebookLoginRequest represents the request body for Facebook login.
// The Flutter app sends the access token obtained from Facebook Login SDK.
type FacebookLoginRequest struct {
	// AccessToken is the token from Facebook Login.
	AccessToken string `json:"access_token"`
}

// AuthResponse represents the response after successful authentication.
type AuthResponse struct {
	// AccessToken is the JWT token for subsequent API requests.
	AccessToken string `json:"access_token"`

	// TokenType is always "Bearer".
	TokenType string `json:"token_type"`

	// ExpiresIn is the token expiry duration in seconds.
	ExpiresIn int64 `json:"expires_in"`

	// User is the authenticated user's profile.
	User *UserPublicProfile `json:"user"`
}

// UserPublicProfile is the public-facing user data returned in API responses.
type UserPublicProfile struct {
	ID        string `json:"id"`
	Email     string `json:"email"`
	FullName  string `json:"full_name"`
	AvatarURL string `json:"avatar_url,omitempty"`
	Role      string `json:"role"`
}

// RoleUpdateRequest represents the request body for updating user role.
type RoleUpdateRequest struct {
	// Role is the selected role (buyer, seller, driver).
	Role string `json:"role"`
}

// RoleUpdateResponse represents the response after updating user role.
type RoleUpdateResponse struct {
	Message string `json:"message"`
	Role    string `json:"role"`
}

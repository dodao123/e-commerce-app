// Package service provides business logic for the application.
package service

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

// googleTokenInfo represents the response from Google's tokeninfo endpoint.
type googleTokenInfo struct {
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	Locale        string `json:"locale"`
	Aud           string `json:"aud"`
}

// GoogleVerifier validates Google ID tokens and extracts user profile.
type GoogleVerifier struct {
	clientID string
}

// NewGoogleVerifier creates a new GoogleVerifier instance.
func NewGoogleVerifier(clientID string) *GoogleVerifier {
	return &GoogleVerifier{clientID: clientID}
}

// VerifyIDToken validates a Google ID token and returns the user profile.
// Calls Google's tokeninfo endpoint to verify the token.
func (verifier *GoogleVerifier) VerifyIDToken(
	idToken string,
) (*SocialProfile, error) {
	url := "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken

	response, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to verify Google token: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(response.Body)
		log.Printf("🔴 Google tokeninfo error (%d): %s", response.StatusCode, string(body))
		return nil, fmt.Errorf("invalid Google token (status %d)", response.StatusCode)
	}

	var tokenInfo googleTokenInfo
	if err := json.NewDecoder(response.Body).Decode(&tokenInfo); err != nil {
		return nil, fmt.Errorf("failed to decode Google response: %w", err)
	}

	log.Printf("🔵 Google token aud: %s", tokenInfo.Aud)
	log.Printf("🔵 Backend clientID: %s", verifier.clientID)

	// Validate audience matches our client ID
	if verifier.clientID != "" && tokenInfo.Aud != verifier.clientID {
		log.Printf("🔴 Audience mismatch! token=%s expected=%s", tokenInfo.Aud, verifier.clientID)
		return nil, fmt.Errorf("Google token audience mismatch")
	}

	log.Printf("🟢 Google verified: %s (%s)", tokenInfo.Email, tokenInfo.Sub)

	return &SocialProfile{
		ProviderID:    tokenInfo.Sub,
		Email:         tokenInfo.Email,
		EmailVerified: tokenInfo.EmailVerified == "true",
		FullName:      tokenInfo.Name,
		AvatarURL:     tokenInfo.Picture,
		Locale:        tokenInfo.Locale,
	}, nil
}

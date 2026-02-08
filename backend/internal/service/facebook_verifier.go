// Package service provides business logic for the application.
package service

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// facebookUserResponse represents the response from Facebook's Graph API.
type facebookUserResponse struct {
	ID      string          `json:"id"`
	Name    string          `json:"name"`
	Email   string          `json:"email"`
	Picture *facebookPicture `json:"picture"`
}

// facebookPicture represents the nested picture structure from Facebook.
type facebookPicture struct {
	Data *facebookPictureData `json:"data"`
}

// facebookPictureData holds the actual picture URL from Facebook.
type facebookPictureData struct {
	URL string `json:"url"`
}

// FacebookVerifier validates Facebook access tokens and extracts user profile.
type FacebookVerifier struct {
	appID     string
	appSecret string
}

// NewFacebookVerifier creates a new FacebookVerifier instance.
func NewFacebookVerifier(appID, appSecret string) *FacebookVerifier {
	return &FacebookVerifier{appID: appID, appSecret: appSecret}
}

// VerifyAccessToken validates a Facebook access token and returns the user profile.
// Calls Facebook's Graph API /me endpoint to fetch user data.
func (verifier *FacebookVerifier) VerifyAccessToken(
	accessToken string,
) (*SocialProfile, error) {
	url := "https://graph.facebook.com/me" +
		"?fields=id,name,email,picture.type(large)" +
		"&access_token=" + accessToken

	response, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to verify Facebook token: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf(
			"invalid Facebook token (status %d)", response.StatusCode,
		)
	}

	var userInfo facebookUserResponse
	if err := json.NewDecoder(response.Body).Decode(&userInfo); err != nil {
		return nil, fmt.Errorf("failed to decode Facebook response: %w", err)
	}

	avatarURL := ""
	if userInfo.Picture != nil && userInfo.Picture.Data != nil {
		avatarURL = userInfo.Picture.Data.URL
	}

	return &SocialProfile{
		ProviderID:    userInfo.ID,
		Email:         userInfo.Email,
		EmailVerified: userInfo.Email != "",
		FullName:      userInfo.Name,
		AvatarURL:     avatarURL,
	}, nil
}

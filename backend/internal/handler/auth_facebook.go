// Package handler provides HTTP request handlers for the API.
package handler

import (
	"delivery-app/backend/internal/model"
	"net/http"
)

// HandleFacebookLogin processes Facebook Login requests.
// Accepts POST with {"access_token": "..."} body.
func (handler *AuthHandler) HandleFacebookLogin(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed, "POST only")
		return
	}

	var loginRequest model.FacebookLoginRequest
	if err := ReadJSON(request, &loginRequest); err != nil {
		WriteError(writer, http.StatusBadRequest, "Invalid request body")
		return
	}

	if loginRequest.AccessToken == "" {
		WriteError(
			writer, http.StatusBadRequest, "access_token is required",
		)
		return
	}

	profile, err := handler.facebookVerifier.VerifyAccessToken(
		loginRequest.AccessToken,
	)
	if err != nil {
		WriteError(
			writer, http.StatusUnauthorized,
			"Invalid Facebook token: "+err.Error(),
		)
		return
	}

	handler.handleSocialLogin(writer, profile, model.ProviderFacebook)
}

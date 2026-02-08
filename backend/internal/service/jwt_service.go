// Package service provides business logic for the application.
package service

import (
	"delivery-app/backend/internal/config"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// JWTClaims represents the custom claims stored in a JWT token.
type JWTClaims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// JWTService handles JWT token generation and validation.
type JWTService struct {
	secret     []byte
	expiryHours int
}

// NewJWTService creates a new JWTService instance.
func NewJWTService(authConfig *config.AuthConfig) *JWTService {
	return &JWTService{
		secret:      []byte(authConfig.JWTSecret),
		expiryHours: authConfig.JWTExpiryHours,
	}
}

// GenerateToken creates a signed JWT token for a user.
func (service *JWTService) GenerateToken(
	userID, email, role string,
) (string, error) {
	expiresAt := time.Now().Add(
		time.Duration(service.expiryHours) * time.Hour,
	)

	claims := JWTClaims{
		UserID: userID,
		Email:  email,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "delivery-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	signedToken, err := token.SignedString(service.secret)
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	return signedToken, nil
}

// ExpirySeconds returns the token expiry duration in seconds.
func (service *JWTService) ExpirySeconds() int64 {
	return int64(service.expiryHours) * 3600
}

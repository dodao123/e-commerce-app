// Package service provides business logic for the application.
package service

import (
	"fmt"

	"github.com/golang-jwt/jwt/v5"
)

// ValidateToken parses and validates a JWT token string.
// Returns the claims if the token is valid, or an error otherwise.
func (service *JWTService) ValidateToken(
	tokenString string,
) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&JWTClaims{},
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf(
					"unexpected signing method: %v",
					token.Header["alg"],
				)
			}
			return service.secret, nil
		},
	)

	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token claims")
	}

	return claims, nil
}

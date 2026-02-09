// Package service provides business logic for the application.
package service

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

// BcryptService handles password hashing and verification.
type BcryptService struct {
	cost int
}

// NewBcryptService creates a new BcryptService with default cost.
func NewBcryptService() *BcryptService {
	return &BcryptService{cost: bcrypt.DefaultCost}
}

// HashPassword generates a bcrypt hash from a plaintext password.
func (svc *BcryptService) HashPassword(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword(
		[]byte(password), svc.cost,
	)
	if err != nil {
		return "", fmt.Errorf("failed to hash password: %w", err)
	}
	return string(hash), nil
}

// ComparePassword checks if a plaintext password matches a hash.
func (svc *BcryptService) ComparePassword(
	hash, password string,
) bool {
	err := bcrypt.CompareHashAndPassword(
		[]byte(hash), []byte(password),
	)
	return err == nil
}

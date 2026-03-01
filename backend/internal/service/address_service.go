// Package service provides address business logic.
package service

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
)

// AddressService handles address business logic.
type AddressService struct {
	repo *repository.PostgresAddressRepository
}

// NewAddressService creates a new AddressService.
func NewAddressService(
	repo *repository.PostgresAddressRepository,
) *AddressService {
	return &AddressService{repo: repo}
}

// Create saves a new address.
func (s *AddressService) Create(
	addr model.DeliveryAddress,
) (*model.DeliveryAddress, error) {
	return s.repo.Create(addr)
}

// ListByUser returns addresses for a user.
func (s *AddressService) ListByUser(
	userID string,
) ([]model.DeliveryAddress, error) {
	return s.repo.ListByUser(userID)
}

// GetByID returns a single address.
func (s *AddressService) GetByID(
	id string,
) (*model.DeliveryAddress, error) {
	return s.repo.GetByID(id)
}

// Delete removes an address.
func (s *AddressService) Delete(id string) error {
	return s.repo.Delete(id)
}

package service

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
)

// ShipperService handles shipper profile operations.
type ShipperService struct {
	repo *repository.PostgresShipperRepository
}

// NewShipperService creates a new instance.
func NewShipperService(repo *repository.PostgresShipperRepository) *ShipperService {
	return &ShipperService{repo: repo}
}

// GetProfile returns the profile for a driver.
func (s *ShipperService) GetProfile(userID string) (*model.ShipperProfile, error) {
	return s.repo.GetByUserID(userID)
}

// SaveProfile inserts or updates the profile.
func (s *ShipperService) SaveProfile(userID string, req model.ShipperProfileRequest) (*model.ShipperProfile, error) {
	profile := &model.ShipperProfile{
		UserID:            userID,
		FullName:          req.FullName,
		NationalID:        req.NationalID,
		VehicleType:       req.VehicleType,
		LicensePlate:      req.LicensePlate,
		OperatingRadiusKM: req.OperatingRadiusKM,
		Latitude:          req.Latitude,
		Longitude:         req.Longitude,
		Province:          req.Province,
		District:          req.District,
		Ward:              req.Ward,
		DetailAddress:     req.DetailAddress,
	}
	if err := s.repo.UpsertProfile(profile); err != nil {
		return nil, err
	}
	// Return the saved profile with timestamps
	return s.repo.GetByUserID(userID)
}

package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
)

// PostgresShipperRepository provides access to shipper profiles.
type PostgresShipperRepository struct {
	db *sql.DB
}

// NewPostgresShipperRepository creates a new instance.
func NewPostgresShipperRepository(db *sql.DB) *PostgresShipperRepository {
	return &PostgresShipperRepository{db: db}
}

// GetByUserID returns the shipper profile for a given user.
func (r *PostgresShipperRepository) GetByUserID(userID string) (*model.ShipperProfile, error) {
	var p model.ShipperProfile
	err := r.db.QueryRow(`
		SELECT user_id, full_name, national_id, vehicle_type,
		       license_plate, operating_radius_km, latitude, longitude,
		       province, district, ward, detail_address, created_at, updated_at
		FROM shipper_profiles WHERE user_id = $1`, userID,
	).Scan(&p.UserID, &p.FullName, &p.NationalID, &p.VehicleType,
		&p.LicensePlate, &p.OperatingRadiusKM, &p.Latitude, &p.Longitude,
		&p.Province, &p.District, &p.Ward, &p.DetailAddress, &p.CreatedAt, &p.UpdatedAt)

	if err == sql.ErrNoRows {
		return nil, nil // Not registered yet
	}
	if err != nil {
		return nil, err
	}
	return &p, nil
}

// UpsertProfile inserts or updates a shipper profile.
func (r *PostgresShipperRepository) UpsertProfile(p *model.ShipperProfile) error {
	query := `
		INSERT INTO shipper_profiles (
			user_id, full_name, national_id, vehicle_type,
			license_plate, operating_radius_km, latitude, longitude,
			province, district, ward, detail_address, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())
		ON CONFLICT (user_id) DO UPDATE SET
			full_name = EXCLUDED.full_name,
			national_id = EXCLUDED.national_id,
			vehicle_type = EXCLUDED.vehicle_type,
			license_plate = EXCLUDED.license_plate,
			operating_radius_km = EXCLUDED.operating_radius_km,
			latitude = EXCLUDED.latitude,
			longitude = EXCLUDED.longitude,
			province = EXCLUDED.province,
			district = EXCLUDED.district,
			ward = EXCLUDED.ward,
			detail_address = EXCLUDED.detail_address,
			updated_at = NOW()
	`
	_, err := r.db.Exec(query, p.UserID, p.FullName, p.NationalID, p.VehicleType, p.LicensePlate, p.OperatingRadiusKM, p.Latitude, p.Longitude, p.Province, p.District, p.Ward, p.DetailAddress)
	if err != nil {
		return fmt.Errorf("upsert shipper profile failed: %w", err)
	}
	return nil
}

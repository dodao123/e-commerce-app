package migration

// CreateShipperProfilesSQL creates the shipper_profiles table.
const CreateShipperProfilesSQL = `
	CREATE TABLE IF NOT EXISTS shipper_profiles (
		user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
		full_name VARCHAR(255) NOT NULL,
		national_id VARCHAR(50) NOT NULL,
		vehicle_type VARCHAR(100) NOT NULL,
		license_plate VARCHAR(50) NOT NULL,
		operating_radius_km NUMERIC(5, 2) NOT NULL DEFAULT 10.00,
		created_at TIMESTAMP NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMP NOT NULL DEFAULT NOW()
	);
`

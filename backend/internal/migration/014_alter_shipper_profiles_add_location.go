package migration

// AlterShipperProfilesAddLocationSQL adds location fields to shipper profiles.
const AlterShipperProfilesAddLocationSQL = `
	ALTER TABLE shipper_profiles 
	ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
	ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
	ADD COLUMN IF NOT EXISTS province VARCHAR(255),
	ADD COLUMN IF NOT EXISTS district VARCHAR(255),
	ADD COLUMN IF NOT EXISTS ward VARCHAR(255),
	ADD COLUMN IF NOT EXISTS detail_address TEXT;
`

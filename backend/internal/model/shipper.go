package model

import "time"

// ShipperProfile holds a driver's details.
type ShipperProfile struct {
	UserID            string    `json:"user_id"`
	FullName          string    `json:"full_name"`
	NationalID        string    `json:"national_id"`
	VehicleType       string    `json:"vehicle_type"`
	LicensePlate      string    `json:"license_plate"`
	OperatingRadiusKM float64   `json:"operating_radius_km"`
	Latitude          *float64  `json:"lat,omitempty"`
	Longitude         *float64  `json:"lng,omitempty"`
	Province          *string   `json:"province,omitempty"`
	District          *string   `json:"district,omitempty"`
	Ward              *string   `json:"ward,omitempty"`
	DetailAddress     *string   `json:"detail_address,omitempty"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

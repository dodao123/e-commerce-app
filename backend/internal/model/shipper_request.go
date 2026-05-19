package model

// ShipperProfileRequest is the payload for updating a shipper profile.
type ShipperProfileRequest struct {
	FullName          string  `json:"full_name" validate:"required"`
	NationalID        string  `json:"national_id" validate:"required"`
	VehicleType       string  `json:"vehicle_type" validate:"required"`
	LicensePlate      string   `json:"license_plate" validate:"required"`
	OperatingRadiusKM float64  `json:"operating_radius_km" validate:"required,min=1,max=50"`
	Latitude          *float64 `json:"lat"`
	Longitude         *float64 `json:"lng"`
	Province          *string  `json:"province"`
	District          *string  `json:"district"`
	Ward              *string  `json:"ward"`
	DetailAddress     *string  `json:"detail_address"`
}

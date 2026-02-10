// Package model defines data structures for database entities.
package model

// CreateShopRequest represents the payload for creating a new shop.
// Matches the Flutter frontend shop registration form.
type CreateShopRequest struct {
	// ShopName is the display name of the shop.
	ShopName string `json:"shop_name" validate:"required,min=3,max=100"`

	// Category is the business category.
	Category string `json:"category" validate:"required"`

	// Province is the shop's province/city.
	Province string `json:"province" validate:"required"`

	// District is the shop's district.
	District string `json:"district" validate:"required"`

	// Ward is the shop's ward/commune.
	Ward string `json:"ward" validate:"required"`

	// DetailAddress is the detailed street address.
	DetailAddress string `json:"detail_address" validate:"required,min=5"`

	// Email is the shop's contact email.
	Email string `json:"email" validate:"required,email"`

	// Phone is the shop's contact phone number.
	Phone string `json:"phone" validate:"required"`

	// Nationality is the shop owner's nationality.
	Nationality string `json:"nationality" validate:"required"`

	// NationalIDNumber is the CCCD/ID card number.
	NationalIDNumber string `json:"national_id_number" validate:"required"`

	// FullName is the legal name (optional).
	FullName string `json:"full_name,omitempty"`
}

// UpdateShopRequest represents the payload for updating shop information.
type UpdateShopRequest struct {
	// ShopName is the display name of the shop.
	ShopName *string `json:"shop_name,omitempty" validate:"omitempty,min=3,max=100"`

	// Category is the business category.
	Category *string `json:"category,omitempty"`

	// Province is the shop's province/city.
	Province *string `json:"province,omitempty"`

	// District is the shop's district.
	District *string `json:"district,omitempty"`

	// Ward is the shop's ward/commune.
	Ward *string `json:"ward,omitempty"`

	// DetailAddress is the detailed street address.
	DetailAddress *string `json:"detail_address,omitempty" validate:"omitempty,min=5"`

	// Nationality is the shop owner's nationality.
	Nationality *string `json:"nationality,omitempty"`

	// NationalIDNumber is the CCCD/ID card number.
	NationalIDNumber *string `json:"national_id_number,omitempty"`

	// FullName is the legal name of the shop owner.
	FullName *string `json:"full_name,omitempty" validate:"omitempty,min=2"`
}

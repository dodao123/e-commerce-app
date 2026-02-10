// Package model defines data structures for database entities.
package model

import "time"

// ShopCategory represents the business category of a shop.
type ShopCategory string

const (
	// CategoryFashion represents fashion and clothing shops.
	CategoryFashion ShopCategory = "fashion"

	// CategoryElectronics represents electronics shops.
	CategoryElectronics ShopCategory = "electronics"

	// CategoryFood represents food and beverage shops.
	CategoryFood ShopCategory = "food"

	// CategoryBeauty represents beauty and cosmetics shops.
	CategoryBeauty ShopCategory = "beauty"

	// CategoryHome represents home and living shops.
	CategoryHome ShopCategory = "home"

	// CategorySports represents sports and outdoor shops.
	CategorySports ShopCategory = "sports"

	// CategoryOther represents other categories.
	CategoryOther ShopCategory = "other"
)

// Shop represents a seller's shop in the e-commerce platform.
// Contains business information and identity verification data.
type Shop struct {
	// ID is the primary key (UUID).
	ID string `json:"id"`

	// SellerID references the user who owns this shop.
	SellerID string `json:"seller_id"`

	// ShopName is the display name of the shop.
	ShopName string `json:"shop_name"`

	// Category is the business category.
	Category ShopCategory `json:"category"`

	// Province is the shop's province/city.
	Province string `json:"province"`

	// District is the shop's district.
	District string `json:"district"`

	// Ward is the shop's ward/commune.
	Ward string `json:"ward"`

	// DetailAddress is the detailed street address.
	DetailAddress string `json:"detail_address"`

	// Email is the shop's contact email.
	Email string `json:"email"`

	// Phone is the shop's contact phone number.
	Phone string `json:"phone"`

	// Nationality is the shop owner's nationality.
	Nationality string `json:"nationality"`

	// NationalIDNumber is the CCCD/ID card number.
	NationalIDNumber string `json:"national_id_number"`

	// FullName is the legal name of the shop owner.
	FullName string `json:"full_name"`

	// IsVerified indicates if the shop has been verified by admin.
	IsVerified bool `json:"is_verified"`

	// IsActive indicates if the shop is currently active.
	IsActive bool `json:"is_active"`

	// CreatedAt is when the shop was registered.
	CreatedAt time.Time `json:"created_at"`

	// UpdatedAt is when the shop info was last modified.
	UpdatedAt time.Time `json:"updated_at"`
}

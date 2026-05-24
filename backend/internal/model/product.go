// Package model defines data structures for database entities.
package model

import "time"

// ProductCondition represents item condition (new or used).
type ProductCondition string

const (
	// ConditionNew represents a brand new product.
	ConditionNew ProductCondition = "new"

	// ConditionUsed represents a used/secondhand product.
	ConditionUsed ProductCondition = "used"
)

// ProductCategory represents the category of a product.
type ProductCategory string

const (
	// ProdCatPhones represents phones category.
	ProdCatPhones ProductCategory = "phones"

	// ProdCatComputers represents computers and laptops.
	ProdCatComputers ProductCategory = "computers"

	// ProdCatElectronics represents general electronics.
	ProdCatElectronics ProductCategory = "electronics"

	// ProdCatFashion represents fashion and clothing.
	ProdCatFashion ProductCategory = "fashion"

	// ProdCatBeauty represents beauty and cosmetics.
	ProdCatBeauty ProductCategory = "beauty"

	// ProdCatHomeAppliances represents home appliances.
	ProdCatHomeAppliances ProductCategory = "home_appliances"

	// ProdCatFootwear represents shoes and footwear.
	ProdCatFootwear ProductCategory = "footwear"

	// ProdCatCooling represents cooling and AC equipment.
	ProdCatCooling ProductCategory = "cooling"

	// ProdCatMomBaby represents mom and baby products.
	ProdCatMomBaby ProductCategory = "mom_baby"

	// ProdCatFood represents food and beverages.
	ProdCatFood ProductCategory = "food"

	// ProdCatGaming represents gaming products.
	ProdCatGaming ProductCategory = "gaming"

	// ProdCatOther represents other categories.
	ProdCatOther ProductCategory = "other"
)

// Product represents a product listed by a seller.
// Stored in the products table.
type Product struct {
	// ID is the primary key (UUID).
	ID string `json:"id"`

	// ShopID references the shop that owns this product.
	ShopID string `json:"shop_id"`

	// Name is the product display name.
	Name string `json:"name"`

	// Description is the product detail description.
	Description string `json:"description"`

	// Category is the product category.
	Category ProductCategory `json:"category"`

	// Price is the product price in VND.
	Price float64 `json:"price"`

	// Stock is the available inventory count.
	Stock int `json:"stock"`

	// BaseShippingFee is the base fee before distance factor.
	BaseShippingFee float64 `json:"base_shipping_fee"`

	// Condition indicates new or used status.
	Condition ProductCondition `json:"condition"`

	// ConditionNote is optional detail (e.g. "99% new").
	ConditionNote string `json:"condition_note"`

	// Options is a list of variant option groups.
	Options []ProductOption `json:"options"`

	// Images is a list of image URLs (max 10).
	Images []string `json:"images"`

	// VideoURL is an optional product video link.
	VideoURL string `json:"video_url"`

	// Status is the product listing status
	// (active, inactive, pending, violated).
	Status string `json:"status"`

	// CreatedAt is when the product was created.
	CreatedAt time.Time `json:"created_at"`

	// UpdatedAt is when the product was last modified.
	UpdatedAt time.Time `json:"updated_at"`
}

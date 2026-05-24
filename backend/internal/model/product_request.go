// Package model defines data structures for database entities.
package model

// CreateProductRequest is the payload for creating a product.
// Matches the Flutter add product form.
type CreateProductRequest struct {
	// Name is the product display name.
	Name string `json:"name" validate:"required,min=3,max=120"`

	// Description is the product detail text.
	Description string `json:"description" validate:"required,min=10,max=3000"`

	// Category is the product category key.
	Category string `json:"category" validate:"required"`

	// Price is the price in VND.
	Price float64 `json:"price" validate:"required,gt=0"`

	// Stock is the inventory count.
	Stock int `json:"stock" validate:"required,gte=0"`

	// BaseShippingFee is the base shipping cost.
	BaseShippingFee float64 `json:"base_shipping_fee" validate:"gte=0"`

	// Condition is "new" or "used".
	Condition string `json:"condition" validate:"required,oneof=new used"`

	// ConditionNote is an optional detail (e.g. "99% new").
	ConditionNote string `json:"condition_note,omitempty" validate:"max=200"`

	// Options is a list of variant option groups.
	Options []ProductOption `json:"options,omitempty"`

	// Images is a list of image URLs (max 10).
	Images []string `json:"images" validate:"max=10"`

	// VideoURL is an optional video link.
	VideoURL string `json:"video_url,omitempty" validate:"omitempty,url"`
}

// UpdateProductRequest is the payload for updating a product.
// All fields are optional (pointer types).
type UpdateProductRequest struct {
	// Name is the product display name.
	Name *string `json:"name,omitempty" validate:"omitempty,min=3,max=120"`

	// Description is the product detail text.
	Description *string `json:"description,omitempty" validate:"omitempty,min=10,max=3000"`

	// Category is the product category key.
	Category *string `json:"category,omitempty"`

	// Price is the price in VND.
	Price *float64 `json:"price,omitempty" validate:"omitempty,gt=0"`

	// Stock is the inventory count.
	Stock *int `json:"stock,omitempty" validate:"omitempty,gte=0"`

	// BaseShippingFee is the base shipping cost.
	BaseShippingFee *float64 `json:"base_shipping_fee,omitempty" validate:"omitempty,gte=0"`

	// Condition is "new" or "used".
	Condition *string `json:"condition,omitempty" validate:"omitempty,oneof=new used"`

	// ConditionNote is an optional detail.
	ConditionNote *string `json:"condition_note,omitempty" validate:"omitempty,max=200"`

	// Options is a list of variant option groups.
	Options *[]ProductOption `json:"options,omitempty"`

	// Images is a list of image URLs (max 10).
	Images *[]string `json:"images,omitempty" validate:"omitempty,max=10"`

	// VideoURL is an optional video link.
	VideoURL *string `json:"video_url,omitempty" validate:"omitempty,url"`

	// Status is the listing status.
	Status *string `json:"status,omitempty" validate:"omitempty,oneof=active inactive pending violated"`
}

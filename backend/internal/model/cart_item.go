// Package model defines data structures for database entities.
package model

import "time"

// CartItem represents a single item in a buyer's shopping cart.
// Links to products table (which chains to shops → seller).
type CartItem struct {
	// ID is the primary key (UUID).
	ID string `json:"id"`

	// UserID references the buyer who owns this cart item.
	UserID string `json:"user_id"`

	// ProductID references the product added to cart.
	ProductID string `json:"product_id"`

	// Quantity is the number of units.
	Quantity int `json:"quantity"`

	// CreatedAt is when the item was added.
	CreatedAt time.Time `json:"created_at"`

	// UpdatedAt is when the item was last modified.
	UpdatedAt time.Time `json:"updated_at"`
}

// CartItemDetail includes product and shop info for display.
// Built by JOINing cart_items → products → shops.
type CartItemDetail struct {
	// CartItem embeds the base cart item fields.
	CartItem

	// ProductName is the product display name.
	ProductName string `json:"product_name"`

	// ProductImage is the first image URL of the product.
	ProductImage string `json:"product_image"`

	// Price is the unit price of the product.
	Price float64 `json:"price"`

	// ShopID is the shop that sells this product.
	ShopID string `json:"shop_id"`

	// ShopName is the display name of the shop.
	ShopName string `json:"shop_name"`

	// ShopAvatar is the seller's profile picture URL.
	ShopAvatar string `json:"shop_avatar"`

	// ProductOptions contains the product variant option groups.
	ProductOptions []ProductOption `json:"product_options"`
}

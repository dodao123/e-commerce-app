// Package model defines data structures for database entities.
package model

// PublicProduct represents a product with shop info for public listing.
// Used by the public products endpoint to display products from all shops.
type PublicProduct struct {
	// Product embeds all base product fields.
	Product

	// ShopName is the display name of the seller's shop.
	ShopName string `json:"shop_name"`

	// ShopProvince is the shop's location province/city.
	ShopProvince string `json:"shop_province"`

	// ShopAvatar is the seller's profile picture URL.
	ShopAvatar string `json:"shop_avatar"`
}

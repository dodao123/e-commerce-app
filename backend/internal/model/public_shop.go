package model

// PublicShop represents public shop details including the shop's avatar URL.
type PublicShop struct {
	// Shop embeds all base shop fields.
	Shop

	// ShopAvatar is the URL to the shop's avatar/logo.
	ShopAvatar string `json:"shop_avatar"`
}

// Package repository defines data access interfaces.
package repository

import (
	"context"
	"delivery-app/backend/internal/model"
)

// ShopRepository defines methods for shop data access.
type ShopRepository interface {
	// CreateShop creates a new shop for a seller.
	CreateShop(ctx context.Context, shop *model.Shop) error

	// GetShopByID retrieves a shop by its ID.
	GetShopByID(ctx context.Context, shopID string) (*model.Shop, error)

	// GetShopBySellerID retrieves a shop by seller user ID.
	GetShopBySellerID(ctx context.Context, sellerID string) (*model.Shop, error)

	// UpdateShop updates shop information.
	UpdateShop(ctx context.Context, shop *model.Shop) error

	// DeleteShop soft-deletes a shop (sets is_active to false).
	DeleteShop(ctx context.Context, shopID string) error

	// ListShops retrieves all shops with pagination.
	ListShops(
		ctx context.Context,
		limit int,
		offset int,
	) ([]*model.Shop, error)

	// ListShopsByCategory retrieves shops by category with pagination.
	ListShopsByCategory(
		ctx context.Context,
		category model.ShopCategory,
		limit int,
		offset int,
	) ([]*model.Shop, error)
}

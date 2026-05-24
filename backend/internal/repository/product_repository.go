// Package repository defines data access interfaces.
package repository

import (
	"context"
	"delivery-app/backend/internal/model"
)

// ProductRepository defines methods for product data access.
type ProductRepository interface {
	// CreateProduct inserts a new product.
	CreateProduct(
		ctx context.Context,
		product *model.Product,
	) error

	// GetProductByID retrieves a product by its ID.
	GetProductByID(
		ctx context.Context,
		productID string,
	) (*model.Product, error)

	// ListProductsByShop retrieves products for a shop.
	ListProductsByShop(
		ctx context.Context,
		shopID string,
		status string,
		limit int,
		offset int,
	) ([]*model.Product, error)

	// ListAllPublicProducts retrieves active products from all shops.
	ListAllPublicProducts(
		ctx context.Context,
		category string,
		limit int,
		offset int,
	) ([]*model.PublicProduct, error)

	// ListProductsByShopPublic retrieves active products by shop ID.
	ListProductsByShopPublic(
		ctx context.Context,
		shopID string,
		excludeID string,
		limit int,
	) ([]*model.PublicProduct, error)

	// UpdateProduct updates product information.
	UpdateProduct(
		ctx context.Context,
		product *model.Product,
	) error

	// DeleteProduct removes a product by its ID.
	DeleteProduct(
		ctx context.Context,
		productID string,
	) error
}

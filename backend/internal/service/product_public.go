// Package service provides business logic for operations.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
)

// ListPublicProducts retrieves active products from all shops, optionally filtered by category.
// This is used by the public home page endpoint.
func (service *ProductService) ListPublicProducts(
	ctx context.Context,
	category string,
	limit int,
	offset int,
) ([]*model.PublicProduct, error) {
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	if offset < 0 {
		offset = 0
	}
	return service.productRepository.ListAllPublicProducts(
		ctx, category, limit, offset)
}

// ListShopProducts retrieves active products for a specific shop.
// Excludes excludeID to avoid showing the current product.
func (service *ProductService) ListShopProducts(
	ctx context.Context,
	shopID string,
	excludeID string,
	limit int,
) ([]*model.PublicProduct, error) {
	if limit <= 0 || limit > 20 {
		limit = 10
	}
	return service.productRepository.ListProductsByShopPublic(
		ctx, shopID, excludeID, limit)
}

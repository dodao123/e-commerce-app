// Package service provides business logic implementations.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"fmt"
)

// GetProduct retrieves a product by its ID.
func (service *ProductService) GetProduct(
	ctx context.Context,
	productID string,
) (*model.Product, error) {
	return service.productRepository.GetProductByID(ctx, productID)
}

// GetShopBySellerID retrieves a shop by seller user ID.
func (service *ProductService) GetShopBySellerID(
	ctx context.Context,
	sellerID string,
) (*model.Shop, error) {
	return service.shopRepository.GetShopBySellerID(ctx, sellerID)
}

// ListProducts retrieves products for a seller's shop.
func (service *ProductService) ListProducts(
	ctx context.Context,
	sellerID string,
	status string,
	limit int,
	offset int,
) ([]*model.Product, error) {
	shop, err := service.shopRepository.GetShopBySellerID(
		ctx, sellerID)
	if err != nil {
		return nil, fmt.Errorf("failed to find shop: %w", err)
	}
	if shop == nil {
		return nil, fmt.Errorf("seller has no shop")
	}

	return service.productRepository.ListProductsByShop(
		ctx, shop.ID, status, limit, offset)
}

// DeleteProduct deletes a product owned by the seller.
// Also removes the product's image folder from disk.
func (service *ProductService) DeleteProduct(
	ctx context.Context,
	sellerID string,
	productID string,
) error {
	product, err := service.productRepository.GetProductByID(
		ctx, productID)
	if err != nil {
		return fmt.Errorf("product not found: %w", err)
	}

	// Verify ownership through shop
	shop, err := service.shopRepository.GetShopBySellerID(
		ctx, sellerID)
	if err != nil || shop == nil || shop.ID != product.ShopID {
		return fmt.Errorf("unauthorized: not product owner")
	}

	// Delete from database first
	if err := service.productRepository.DeleteProduct(
		ctx, productID); err != nil {
		return err
	}

	// Clean up image folder from disk
	_ = service.DeleteProductFolder(shop.ID, productID)

	return nil
}

// UpdateProductImages saves updated image URLs to the database.
func (service *ProductService) UpdateProductImages(
	ctx context.Context,
	product *model.Product,
) error {
	return service.productRepository.UpdateProduct(ctx, product)
}

// UpdateProduct applies partial updates to a seller's product.
func (service *ProductService) UpdateProduct(
	ctx context.Context,
	sellerID string,
	productID string,
	req *model.UpdateProductRequest,
) (*model.Product, error) {
	product, err := service.productRepository.GetProductByID(
		ctx, productID)
	if err != nil {
		return nil, fmt.Errorf("product not found: %w", err)
	}

	shop, err := service.shopRepository.GetShopBySellerID(
		ctx, sellerID)
	if err != nil || shop == nil || shop.ID != product.ShopID {
		return nil, fmt.Errorf("unauthorized: not product owner")
	}

	applyProductUpdates(product, req)

	if err := service.productRepository.UpdateProduct(
		ctx, product); err != nil {
		return nil, err
	}
	return product, nil
}

// applyProductUpdates merges non-nil fields from the request.
func applyProductUpdates(
	product *model.Product,
	req *model.UpdateProductRequest,
) {
	if req.Name != nil {
		product.Name = *req.Name
	}
	if req.Description != nil {
		product.Description = *req.Description
	}
	if req.Category != nil {
		product.Category = model.ProductCategory(*req.Category)
	}
	if req.Price != nil {
		product.Price = *req.Price
	}
	if req.Stock != nil {
		product.Stock = *req.Stock
	}
	if req.BaseShippingFee != nil {
		product.BaseShippingFee = *req.BaseShippingFee
	}
	if req.Condition != nil {
		product.Condition = model.ProductCondition(*req.Condition)
	}
	if req.ConditionNote != nil {
		product.ConditionNote = *req.ConditionNote
	}
	if req.Options != nil {
		product.Options = *req.Options
	}
	if req.Images != nil {
		product.Images = *req.Images
	}
	if req.VideoURL != nil {
		product.VideoURL = *req.VideoURL
	}
	if req.Status != nil {
		product.Status = *req.Status
	}
}

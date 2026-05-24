// Package service provides business logic implementations.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
)

// ProductService handles business logic for product operations.
type ProductService struct {
	productRepository repository.ProductRepository
	shopRepository    repository.ShopRepository
	imageService      *ImageService
}

// NewProductService creates a new product service instance.
func NewProductService(
	productRepository repository.ProductRepository,
	shopRepository repository.ShopRepository,
	imageService *ImageService,
) *ProductService {
	return &ProductService{
		productRepository: productRepository,
		shopRepository:    shopRepository,
		imageService:      imageService,
	}
}

// CreateProduct creates a new product for a seller's shop.
func (service *ProductService) CreateProduct(
	ctx context.Context,
	sellerID string,
	request *model.CreateProductRequest,
) (*model.Product, error) {
	// Get seller's shop
	shop, err := service.shopRepository.GetShopBySellerID(
		ctx, sellerID)
	if err != nil {
		return nil, fmt.Errorf("failed to find shop: %w", err)
	}
	if shop == nil {
		return nil, fmt.Errorf("seller has no shop")
	}

	product := &model.Product{
		ShopID:          shop.ID,
		Name:            request.Name,
		Description:     request.Description,
		Category:        model.ProductCategory(request.Category),
		Price:           request.Price,
		Stock:           request.Stock,
		BaseShippingFee: request.BaseShippingFee,
		Condition:       model.ProductCondition(request.Condition),
		ConditionNote:   request.ConditionNote,
		Options:         request.Options,
		Images:          request.Images,
		VideoURL:        request.VideoURL,
		Status:          "active",
	}

	// Ensure images is never nil for pq.Array
	if product.Images == nil {
		product.Images = []string{}
	}

	if err := service.productRepository.CreateProduct(
		ctx, product); err != nil {
		return nil, fmt.Errorf("failed to create product: %w", err)
	}

	// Create upload folder for this product
	if _, err := service.imageService.EnsureProductFolder(
		shop.ID, product.ID); err != nil {
		fmt.Printf("⚠️ Failed to create folder: %v\n", err)
	}

	return product, nil
}

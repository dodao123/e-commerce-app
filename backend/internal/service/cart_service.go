// Package service provides business logic implementations.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
)

// CartService handles business logic for cart operations.
type CartService struct {
	cartRepository    repository.CartRepository
	productRepository repository.ProductRepository
}

// NewCartService creates a new cart service instance.
func NewCartService(
	cartRepo repository.CartRepository,
	productRepo repository.ProductRepository,
) *CartService {
	return &CartService{
		cartRepository:    cartRepo,
		productRepository: productRepo,
	}
}

// AddItem validates stock and adds a product to the buyer's cart.
func (svc *CartService) AddItem(
	ctx context.Context,
	userID string,
	productID string,
	quantity int,
) (*model.CartItem, error) {
	if quantity <= 0 {
		return nil, fmt.Errorf("quantity must be positive")
	}

	product, err := svc.productRepository.GetProductByID(
		ctx, productID)
	if err != nil {
		return nil, fmt.Errorf("product not found: %w", err)
	}
	if product.Stock < quantity {
		return nil, fmt.Errorf("insufficient stock")
	}

	return svc.cartRepository.AddItem(
		ctx, userID, productID, quantity)
}

// GetCart returns the buyer's cart with full product/shop details.
func (svc *CartService) GetCart(
	ctx context.Context,
	userID string,
) ([]*model.CartItemDetail, error) {
	return svc.cartRepository.GetCartByUser(ctx, userID)
}

// UpdateQuantity changes the quantity of a cart item.
func (svc *CartService) UpdateQuantity(
	ctx context.Context,
	itemID string,
	userID string,
	quantity int,
) error {
	if quantity <= 0 {
		return svc.cartRepository.RemoveItem(
			ctx, itemID, userID)
	}
	return svc.cartRepository.UpdateQuantity(
		ctx, itemID, userID, quantity)
}

// RemoveItem deletes a cart item.
func (svc *CartService) RemoveItem(
	ctx context.Context,
	itemID string,
	userID string,
) error {
	return svc.cartRepository.RemoveItem(
		ctx, itemID, userID)
}

// GetCount returns total item count for badge display.
func (svc *CartService) GetCount(
	ctx context.Context,
	userID string,
) (int, error) {
	return svc.cartRepository.GetCartCount(ctx, userID)
}

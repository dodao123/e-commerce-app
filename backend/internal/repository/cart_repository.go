// Package repository defines data access interfaces.
package repository

import (
	"context"
	"delivery-app/backend/internal/model"
)

// CartRepository defines methods for cart data access.
type CartRepository interface {
	// AddItem inserts or increments a cart item (upsert).
	AddItem(
		ctx context.Context,
		userID string,
		productID string,
		quantity int,
	) (*model.CartItem, error)

	// UpdateQuantity sets the quantity for a cart item.
	UpdateQuantity(
		ctx context.Context,
		itemID string,
		userID string,
		quantity int,
	) error

	// RemoveItem deletes a cart item by ID.
	RemoveItem(
		ctx context.Context,
		itemID string,
		userID string,
	) error

	// GetCartByUser returns all cart items with product/shop info.
	GetCartByUser(
		ctx context.Context,
		userID string,
	) ([]*model.CartItemDetail, error)

	// GetCartCount returns total quantity of items in cart.
	GetCartCount(
		ctx context.Context,
		userID string,
	) (int, error)
}

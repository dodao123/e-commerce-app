// Package repository defines data access interfaces.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
)

// PostgresCartRepository implements CartRepository using PostgreSQL.
type PostgresCartRepository struct {
	database *sql.DB
}

// NewPostgresCartRepository creates a new PostgreSQL cart repository.
func NewPostgresCartRepository(
	database *sql.DB,
) *PostgresCartRepository {
	return &PostgresCartRepository{database: database}
}

// AddItem inserts or increments a cart item (upsert on user+product).
func (repo *PostgresCartRepository) AddItem(
	ctx context.Context,
	userID string,
	productID string,
	quantity int,
) (*model.CartItem, error) {
	query := `
		INSERT INTO cart_items (user_id, product_id, quantity)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, product_id)
		DO UPDATE SET
			quantity = cart_items.quantity + EXCLUDED.quantity,
			updated_at = NOW()
		RETURNING id, user_id, product_id, quantity,
			created_at, updated_at`

	item := &model.CartItem{}
	err := repo.database.QueryRowContext(ctx, query,
		userID, productID, quantity,
	).Scan(
		&item.ID, &item.UserID, &item.ProductID,
		&item.Quantity, &item.CreatedAt, &item.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return item, nil
}

// UpdateQuantity sets the quantity for a cart item.
func (repo *PostgresCartRepository) UpdateQuantity(
	ctx context.Context,
	itemID string,
	userID string,
	quantity int,
) error {
	query := `
		UPDATE cart_items
		SET quantity = $1, updated_at = NOW()
		WHERE id = $2 AND user_id = $3`

	_, err := repo.database.ExecContext(
		ctx, query, quantity, itemID, userID)
	return err
}

// RemoveItem deletes a cart item by ID.
func (repo *PostgresCartRepository) RemoveItem(
	ctx context.Context,
	itemID string,
	userID string,
) error {
	query := `DELETE FROM cart_items
		WHERE id = $1 AND user_id = $2`

	_, err := repo.database.ExecContext(
		ctx, query, itemID, userID)
	return err
}

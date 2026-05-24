// Package repository provides database access implementations.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"time"

	"github.com/lib/pq"
)

// productColumns is the shared SELECT columns list.
const productColumns = `
	id, shop_id, name, description, category,
	price, stock, base_shipping_fee,
	condition, condition_note, options,
	images, video_url, status,
	created_at, updated_at
`

// GetProductByID retrieves a product by its ID.
func (repository *PostgresProductRepository) GetProductByID(
	ctx context.Context,
	productID string,
) (*model.Product, error) {
	query := `SELECT ` + productColumns + ` FROM products WHERE id = $1`

	row := repository.database.QueryRowContext(ctx, query, productID)
	product, err := scanProduct(row)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("product not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get product: %w", err)
	}
	return product, nil
}

// ListProductsByShop retrieves products for a specific shop.
func (repository *PostgresProductRepository) ListProductsByShop(
	ctx context.Context,
	shopID string,
	status string,
	limit int,
	offset int,
) ([]*model.Product, error) {
	query := `SELECT ` + productColumns + `
		FROM products WHERE shop_id = $1`

	args := []any{shopID}
	argIndex := 2

	if status != "" {
		query += fmt.Sprintf(` AND status = $%d`, argIndex)
		args = append(args, status)
		argIndex++
	}

	query += fmt.Sprintf(` ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		argIndex, argIndex+1)
	args = append(args, limit, offset)

	rows, err := repository.database.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list products: %w", err)
	}
	defer rows.Close()

	var products []*model.Product
	for rows.Next() {
		product, scanErr := scanProduct(rows)
		if scanErr != nil {
			return nil, fmt.Errorf("failed to scan product: %w", scanErr)
		}
		products = append(products, product)
	}
	return products, rows.Err()
}

// UpdateProduct updates a product in the database.
func (repository *PostgresProductRepository) UpdateProduct(
	ctx context.Context,
	product *model.Product,
) error {
	product.UpdatedAt = time.Now()
	optionsJSON := model.EncodeProductOptions(product.Options)
	query := `
		UPDATE products SET
			name = $1, description = $2, category = $3,
			price = $4, stock = $5, base_shipping_fee = $6,
			condition = $7, condition_note = $8, options = $9,
			images = $10, video_url = $11,
			status = $12, updated_at = $13
		WHERE id = $14
	`
	_, err := repository.database.ExecContext(ctx, query,
		product.Name, product.Description, product.Category,
		product.Price, product.Stock, product.BaseShippingFee,
		product.Condition, product.ConditionNote, optionsJSON,
		pq.Array(product.Images), product.VideoURL,
		product.Status, product.UpdatedAt, product.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update product: %w", err)
	}
	return nil
}

// DeleteProduct removes a product by its ID.
func (repository *PostgresProductRepository) DeleteProduct(
	ctx context.Context,
	productID string,
) error {
	query := `DELETE FROM products WHERE id = $1`
	_, err := repository.database.ExecContext(ctx, query, productID)
	if err != nil {
		return fmt.Errorf("failed to delete product: %w", err)
	}
	return nil
}

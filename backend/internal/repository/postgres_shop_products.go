// Package repository provides database access implementations.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
)

// ListProductsByShopPublic retrieves active products for a shop.
// Excludes the given product ID to avoid showing current product.
func (repository *PostgresProductRepository) ListProductsByShopPublic(
	ctx context.Context,
	shopID string,
	excludeID string,
	limit int,
) ([]*model.PublicProduct, error) {
	var query string
	var rows *sql.Rows
	var err error

	if excludeID == "" {
		query = `SELECT ` + publicProductColumns +
			publicProductJoin + `
			WHERE p.shop_id = $1 AND p.status = 'active'
			ORDER BY p.created_at DESC LIMIT $2`
		rows, err = repository.database.QueryContext(
			ctx, query, shopID, limit)
	} else {
		query = `SELECT ` + publicProductColumns +
			publicProductJoin + `
			WHERE p.shop_id = $1 AND p.status = 'active'
			AND p.id != $2
			ORDER BY p.created_at DESC LIMIT $3`
		rows, err = repository.database.QueryContext(
			ctx, query, shopID, excludeID, limit)
	}
	if err != nil {
		return nil, fmt.Errorf("list shop products: %w", err)
	}
	defer rows.Close()

	var products []*model.PublicProduct
	for rows.Next() {
		pp, scanErr := scanPublicProduct(rows)
		if scanErr != nil {
			return nil, fmt.Errorf("scan shop product: %w", scanErr)
		}
		products = append(products, pp)
	}
	return products, rows.Err()
}

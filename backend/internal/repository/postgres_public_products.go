// Package repository provides database access implementations.
package repository

import (
	"context"
	"delivery-app/backend/internal/model"
	"fmt"

	"github.com/lib/pq"
)

// publicProductColumns includes product + joined shop + user fields.
const publicProductColumns = `
	p.id, p.shop_id, p.name, p.description, p.category,
	p.price, p.stock, p.base_shipping_fee,
	p.condition, p.condition_note, p.options,
	p.images, p.video_url, p.status,
	p.created_at, p.updated_at,
	s.shop_name, s.province, COALESCE(u.avatar_url, '')
`

// publicProductJoin is the shared FROM + JOIN clause.
const publicProductJoin = `
	FROM products p
	JOIN shops s ON p.shop_id = s.id
	LEFT JOIN users u ON s.seller_id = u.id
`

// ListAllPublicProducts retrieves active products from all shops, optionally filtered by category.
// Joins with the shops table to include shop name and province.
func (repository *PostgresProductRepository) ListAllPublicProducts(
	ctx context.Context,
	category string,
	limit int,
	offset int,
) ([]*model.PublicProduct, error) {
	var query string
	var err error
	var rows interface {
		Close() error
		Err() error
		Next() bool
		Scan(dest ...interface{}) error
	}

	if category != "" {
		if category == "electronics" {
			query = `SELECT ` + publicProductColumns +
				publicProductJoin + `
				WHERE p.status = 'active' AND p.category IN ('electronics', 'phones', 'computers', 'gaming', 'home_appliances', 'cooling')
				ORDER BY p.created_at DESC
				LIMIT $1 OFFSET $2`
			rows, err = repository.database.QueryContext(ctx, query, limit, offset)
		} else {
			query = `SELECT ` + publicProductColumns +
				publicProductJoin + `
				WHERE p.status = 'active' AND p.category = $1
				ORDER BY p.created_at DESC
				LIMIT $2 OFFSET $3`
			rows, err = repository.database.QueryContext(ctx, query, category, limit, offset)
		}
	} else {
		query = `SELECT ` + publicProductColumns +
			publicProductJoin + `
			WHERE p.status = 'active'
			ORDER BY p.created_at DESC
			LIMIT $1 OFFSET $2`
		rows, err = repository.database.QueryContext(ctx, query, limit, offset)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to list public products: %w", err)
	}
	defer rows.Close()

	var products []*model.PublicProduct
	for rows.Next() {
		pp, scanErr := scanPublicProduct(rows)
		if scanErr != nil {
			return nil, fmt.Errorf("scan public product: %w", scanErr)
		}
		products = append(products, pp)
	}
	return products, rows.Err()
}

// scanPublicProduct scans a row into a PublicProduct.
func scanPublicProduct(scanner scannable) (*model.PublicProduct, error) {
	var pp model.PublicProduct
	var optionsRaw []byte
	err := scanner.Scan(
		&pp.ID, &pp.ShopID, &pp.Name,
		&pp.Description, &pp.Category,
		&pp.Price, &pp.Stock, &pp.BaseShippingFee,
		&pp.Condition, &pp.ConditionNote,
		&optionsRaw,
		pq.Array(&pp.Images), &pp.VideoURL,
		&pp.Status, &pp.CreatedAt, &pp.UpdatedAt,
		&pp.ShopName, &pp.ShopProvince, &pp.ShopAvatar,
	)
	if err != nil {
		return nil, err
	}
	pp.Options = model.ParseProductOptions(optionsRaw)
	return &pp, nil
}

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
	search string,
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

	whereClause := "WHERE p.status = 'active'"
	var args []interface{}
	paramCount := 1

	if category != "" {
		if category == "electronics" {
			whereClause += " AND p.category IN ('electronics', 'phones', 'computers', 'gaming', 'home_appliances', 'cooling')"
		} else {
			whereClause += fmt.Sprintf(" AND p.category = $%d", paramCount)
			args = append(args, category)
			paramCount++
		}
	}

	if search != "" {
		whereClause += fmt.Sprintf(" AND (p.name ILIKE $%d OR p.description ILIKE $%d)", paramCount, paramCount+1)
		searchTerm := "%" + search + "%"
		args = append(args, searchTerm, searchTerm)
		paramCount += 2
	}

	query = fmt.Sprintf(`SELECT %s %s %s ORDER BY RANDOM() LIMIT $%d OFFSET $%d`,
		publicProductColumns, publicProductJoin, whereClause, paramCount, paramCount+1)
	args = append(args, limit, offset)

	rows, err = repository.database.QueryContext(ctx, query, args...)

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

// GetPublicProductByID retrieves a single public product by its ID.
func (repository *PostgresProductRepository) GetPublicProductByID(
	ctx context.Context, productID string,
) (*model.PublicProduct, error) {
	query := fmt.Sprintf(`SELECT %s %s WHERE p.id = $1`,
		publicProductColumns, publicProductJoin)
	row := repository.database.QueryRowContext(ctx, query, productID)
	return scanPublicProduct(row)
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

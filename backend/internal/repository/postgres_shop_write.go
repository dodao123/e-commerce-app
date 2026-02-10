// Package repository provides database access implementations.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"time"
)

// UpdateShop updates shop information.
func (repository *PostgresShopRepository) UpdateShop(
	ctx context.Context,
	shop *model.Shop,
) error {
	query := `
		UPDATE shops
		SET shop_name = $1, category = $2, province = $3, district = $4,
			ward = $5, detail_address = $6, nationality = $7,
			national_id_number = $8, full_name = $9, updated_at = $10
		WHERE id = $11
	`

	shop.UpdatedAt = time.Now()

	result, err := repository.database.ExecContext(
		ctx, query,
		shop.ShopName, shop.Category, shop.Province, shop.District,
		shop.Ward, shop.DetailAddress, shop.Nationality,
		shop.NationalIDNumber, shop.FullName, shop.UpdatedAt, shop.ID,
	)

	if err != nil {
		return fmt.Errorf("failed to update shop: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check update result: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("shop not found")
	}

	return nil
}

// DeleteShop soft-deletes a shop (sets is_active to false).
func (repository *PostgresShopRepository) DeleteShop(
	ctx context.Context,
	shopID string,
) error {
	query := `
		UPDATE shops
		SET is_active = false, updated_at = $1
		WHERE id = $2
	`

	result, err := repository.database.ExecContext(
		ctx, query, time.Now(), shopID,
	)

	if err != nil {
		return fmt.Errorf("failed to delete shop: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check delete result: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("shop not found")
	}

	return nil
}

// ListShops retrieves all shops with pagination.
func (repository *PostgresShopRepository) ListShops(
	ctx context.Context,
	limit int,
	offset int,
) ([]*model.Shop, error) {
	query := `
		SELECT id, seller_id, shop_name, category, province, district,
			   ward, detail_address, nationality, national_id_number,
			   full_name, is_verified, is_active, created_at, updated_at
		FROM shops
		WHERE is_active = true
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`

	rows, err := repository.database.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list shops: %w", err)
	}
	defer rows.Close()

	return scanShops(rows)
}

// ListShopsByCategory retrieves shops by category with pagination.
func (repository *PostgresShopRepository) ListShopsByCategory(
	ctx context.Context,
	category model.ShopCategory,
	limit int,
	offset int,
) ([]*model.Shop, error) {
	query := `
		SELECT id, seller_id, shop_name, category, province, district,
			   ward, detail_address, nationality, national_id_number,
			   full_name, is_verified, is_active, created_at, updated_at
		FROM shops
		WHERE category = $1 AND is_active = true
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := repository.database.QueryContext(
		ctx, query, category, limit, offset,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to list shops by category: %w", err)
	}
	defer rows.Close()

	return scanShops(rows)
}

// scanShops is a helper to scan multiple shop rows.
func scanShops(rows *sql.Rows) ([]*model.Shop, error) {
	shops := []*model.Shop{}

	for rows.Next() {
		shop := &model.Shop{}
		err := rows.Scan(
			&shop.ID, &shop.SellerID, &shop.ShopName, &shop.Category,
			&shop.Province, &shop.District, &shop.Ward, &shop.DetailAddress,
			&shop.Nationality, &shop.NationalIDNumber, &shop.FullName,
			&shop.IsVerified, &shop.IsActive, &shop.CreatedAt, &shop.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan shop: %w", err)
		}
		shops = append(shops, shop)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating shops: %w", err)
	}

	return shops, nil
}

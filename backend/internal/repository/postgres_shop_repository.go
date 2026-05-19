// Package repository provides database access implementations.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// PostgresShopRepository implements ShopRepository using PostgreSQL.
type PostgresShopRepository struct {
	database *sql.DB
}

// NewPostgresShopRepository creates a new PostgreSQL shop repository.
func NewPostgresShopRepository(database *sql.DB) *PostgresShopRepository {
	return &PostgresShopRepository{database: database}
}

// CreateShop creates a new shop for a seller.
func (repository *PostgresShopRepository) CreateShop(
	ctx context.Context,
	shop *model.Shop,
) error {
	query := `
		INSERT INTO shops (
			id, seller_id, shop_name, category, province, district,
			ward, detail_address, latitude, longitude, email, phone, nationality,
			national_id_number, full_name, is_verified, is_active,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
	`

	now := time.Now()
	shop.ID = uuid.New().String()
	shop.CreatedAt = now
	shop.UpdatedAt = now

	_, err := repository.database.ExecContext(
		ctx, query,
		shop.ID, shop.SellerID, shop.ShopName, shop.Category,
		shop.Province, shop.District, shop.Ward, shop.DetailAddress,
		shop.Latitude, shop.Longitude, shop.Email, shop.Phone, shop.Nationality,
		shop.NationalIDNumber, shop.FullName,
		shop.IsVerified, shop.IsActive, shop.CreatedAt, shop.UpdatedAt,
	)

	if err != nil {
		return fmt.Errorf("failed to create shop: %w", err)
	}

	return nil
}

// GetShopByID retrieves a shop by its ID.
func (repository *PostgresShopRepository) GetShopByID(
	ctx context.Context,
	shopID string,
) (*model.Shop, error) {
	query := `
		SELECT id, seller_id, shop_name, category, province, district,
			   ward, detail_address, latitude, longitude, email, phone, nationality,
			   national_id_number, full_name, is_verified, is_active,
			   created_at, updated_at
		FROM shops
		WHERE id = $1
	`

	shop := &model.Shop{}
	err := repository.database.QueryRowContext(ctx, query, shopID).Scan(
		&shop.ID, &shop.SellerID, &shop.ShopName, &shop.Category,
		&shop.Province, &shop.District, &shop.Ward, &shop.DetailAddress,
		&shop.Latitude, &shop.Longitude, &shop.Email, &shop.Phone, &shop.Nationality,
		&shop.NationalIDNumber, &shop.FullName,
		&shop.IsVerified, &shop.IsActive, &shop.CreatedAt, &shop.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("shop not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get shop: %w", err)
	}

	return shop, nil
}

// GetShopBySellerID retrieves a shop by seller user ID.
func (repository *PostgresShopRepository) GetShopBySellerID(
	ctx context.Context,
	sellerID string,
) (*model.Shop, error) {
	query := `
		SELECT id, seller_id, shop_name, category, province, district,
			   ward, detail_address, latitude, longitude, email, phone, nationality,
			   national_id_number, full_name, is_verified, is_active,
			   created_at, updated_at
		FROM shops
		WHERE seller_id = $1
	`

	shop := &model.Shop{}
	err := repository.database.QueryRowContext(ctx, query, sellerID).Scan(
		&shop.ID, &shop.SellerID, &shop.ShopName, &shop.Category,
		&shop.Province, &shop.District, &shop.Ward, &shop.DetailAddress,
		&shop.Latitude, &shop.Longitude, &shop.Email, &shop.Phone, &shop.Nationality,
		&shop.NationalIDNumber, &shop.FullName,
		&shop.IsVerified, &shop.IsActive, &shop.CreatedAt, &shop.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get shop by seller: %w", err)
	}

	return shop, nil
}

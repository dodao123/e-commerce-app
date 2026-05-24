// Package repository provides database access implementations.
package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// PostgresProductRepository implements ProductRepository using PostgreSQL.
type PostgresProductRepository struct {
	database *sql.DB
}

// NewPostgresProductRepository creates a new PostgreSQL product repository.
func NewPostgresProductRepository(
	database *sql.DB,
) *PostgresProductRepository {
	return &PostgresProductRepository{database: database}
}

// CreateProduct inserts a new product into the database.
func (repository *PostgresProductRepository) CreateProduct(
	ctx context.Context,
	product *model.Product,
) error {
	query := `
		INSERT INTO products (
			id, shop_id, name, description, category,
			price, stock, base_shipping_fee,
			condition, condition_note, options,
			images, video_url, status,
			created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8,
			$9, $10, $11, $12, $13, $14, $15, $16
		)
	`

	now := time.Now()
	product.ID = uuid.New().String()
	product.CreatedAt = now
	product.UpdatedAt = now

	if product.Status == "" {
		product.Status = "active"
	}

	optionsJSON := model.EncodeProductOptions(product.Options)

	_, err := repository.database.ExecContext(
		ctx, query,
		product.ID, product.ShopID,
		product.Name, product.Description, product.Category,
		product.Price, product.Stock, product.BaseShippingFee,
		product.Condition, product.ConditionNote, optionsJSON,
		pq.Array(product.Images), product.VideoURL,
		product.Status, product.CreatedAt, product.UpdatedAt,
	)

	if err != nil {
		return fmt.Errorf("failed to create product: %w", err)
	}
	return nil
}

// scanProduct scans a single product row into a Product struct.
func scanProduct(row scannable) (*model.Product, error) {
	product := &model.Product{}
	var optionsRaw []byte
	err := row.Scan(
		&product.ID, &product.ShopID,
		&product.Name, &product.Description, &product.Category,
		&product.Price, &product.Stock, &product.BaseShippingFee,
		&product.Condition, &product.ConditionNote,
		&optionsRaw,
		pq.Array(&product.Images), &product.VideoURL,
		&product.Status, &product.CreatedAt, &product.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	product.Options = model.ParseProductOptions(optionsRaw)
	return product, nil
}

// scannable abstracts sql.Row and sql.Rows for reuse.
type scannable interface {
	Scan(dest ...any) error
}

// Package repository defines data access interfaces.
package repository

import (
	"context"
	"delivery-app/backend/internal/model"
	"fmt"
	"os"
	"path/filepath"

	"github.com/lib/pq"
)

// GetCartByUser returns cart items with product and shop details.
// JOINs: cart_items → products → shops for full display data.
func (repo *PostgresCartRepository) GetCartByUser(
	ctx context.Context,
	userID string,
) ([]*model.CartItemDetail, error) {
	query := `
		SELECT ci.id, ci.user_id, ci.product_id, ci.quantity,
			ci.created_at, ci.updated_at,
			p.name, p.images, p.price, p.options,
			s.id, s.shop_name,
			COALESCE(u.avatar_url, '')
		FROM cart_items ci
		JOIN products p ON ci.product_id = p.id
		JOIN shops s ON p.shop_id = s.id
		LEFT JOIN users u ON s.seller_id = u.id
		WHERE ci.user_id = $1
		ORDER BY s.shop_name, ci.created_at DESC`

	rows, err := repo.database.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanCartDetails(rows)
}

// scanCartDetails scans rows into CartItemDetail slices.
func scanCartDetails(
	rows interface {
		Next() bool
		Scan(dest ...interface{}) error
	},
) ([]*model.CartItemDetail, error) {
	var items []*model.CartItemDetail
	for rows.Next() {
		item := &model.CartItemDetail{}
		var images []string
		var optionsRaw []byte
		if err := rows.Scan(
			&item.ID, &item.UserID, &item.ProductID,
			&item.Quantity, &item.CreatedAt, &item.UpdatedAt,
			&item.ProductName, pq.Array(&images),
			&item.Price, &optionsRaw,
			&item.ShopID, &item.ShopName,
			&item.ShopAvatar,
		); err != nil {
			return nil, err
		}
		if len(images) > 0 {
			item.ProductImage = images[0]
		}
		item.ProductOptions = model.ParseProductOptions(optionsRaw)

		// Dynamically resolve ShopAvatar if logo file exists and current avatar is not a Google/external URL
		if !(len(item.ShopAvatar) >= 4 && item.ShopAvatar[:4] == "http") {
			logoPath := filepath.Join("uploads", "logos", fmt.Sprintf("shop_%s.png", item.ShopID))
			if _, err := os.Stat(logoPath); err == nil {
				item.ShopAvatar = fmt.Sprintf("/uploads/logos/shop_%s.png", item.ShopID)
			}
		}

		items = append(items, item)
	}
	return items, nil
}

// GetCartCount returns total number of distinct items in cart.
func (repo *PostgresCartRepository) GetCartCount(
	ctx context.Context,
	userID string,
) (int, error) {
	query := `SELECT COALESCE(SUM(quantity), 0)
		FROM cart_items WHERE user_id = $1`

	var count int
	err := repo.database.QueryRowContext(
		ctx, query, userID).Scan(&count)
	return count, err
}

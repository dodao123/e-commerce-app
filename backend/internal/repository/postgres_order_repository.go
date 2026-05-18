// Package repository provides PostgreSQL order operations.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
)

// PostgresOrderRepository implements order storage.
type PostgresOrderRepository struct {
	db *sql.DB
}

// NewPostgresOrderRepository creates a new instance.
func NewPostgresOrderRepository(
	db *sql.DB,
) *PostgresOrderRepository {
	return &PostgresOrderRepository{db: db}
}

// Create inserts order + items in a transaction.
func (r *PostgresOrderRepository) Create(
	order model.Order, items []model.OrderItem,
) (*model.Order, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	err = tx.QueryRow(`
		INSERT INTO orders
		(user_id, address_id, receiver_name, receiver_phone,
		 receiver_addr, shipping_method, payment_method,
		 subtotal, shipping_fee, total, status, note)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
		RETURNING id, created_at`,
		order.UserID, order.AddressID,
		order.ReceiverName, order.ReceiverPhone,
		order.ReceiverAddr, order.ShippingMethod,
		order.PaymentMethod, order.Subtotal,
		order.ShippingFee, order.Total,
		order.Status, order.Note,
	).Scan(&order.ID, &order.CreatedAt)
	if err != nil {
		return nil, err
	}
	for _, item := range items {
		if _, err := tx.Exec(`
			INSERT INTO order_items
			(order_id, product_id, product_name,
			 product_image, price, quantity, shop_id, shop_name)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
			order.ID, item.ProductID, item.ProductName,
			item.ProductImage, item.Price, item.Quantity,
			item.ShopID, item.ShopName,
		); err != nil {
			return nil, err
		}
	}
	return &order, tx.Commit()
}

// ListByUser returns orders for a buyer.
func (r *PostgresOrderRepository) ListByUser(
	userID string,
) ([]model.Order, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, receiver_name, receiver_phone,
		       subtotal, shipping_fee, total, status,
		       note, created_at, shipper_id, shipper_name, shipper_phone
		FROM orders WHERE user_id=$1
		ORDER BY created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanOrderRows(rows)
}

// ListByShop returns orders for a seller's shop.
func (r *PostgresOrderRepository) ListByShop(
	shopID string,
) ([]model.Order, error) {
	rows, err := r.db.Query(`
		SELECT DISTINCT o.id, o.user_id,
		       o.receiver_name, o.receiver_phone,
		       o.subtotal, o.shipping_fee, o.total,
		       o.status, o.note, o.created_at,
		       o.shipper_id, o.shipper_name, o.shipper_phone
		FROM orders o
		JOIN order_items oi ON oi.order_id = o.id
		WHERE oi.shop_id = $1
		ORDER BY o.created_at DESC`, shopID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanOrderRows(rows)
}

// ListByShipper returns orders assigned to a driver.
func (r *PostgresOrderRepository) ListByShipper(
	shipperID string,
) ([]model.Order, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, receiver_name, receiver_phone,
		       subtotal, shipping_fee, total, status,
		       note, created_at, shipper_id, shipper_name, shipper_phone
		FROM orders
		WHERE shipper_id = $1 OR status = 'finding_driver'
		ORDER BY created_at DESC`, shipperID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanOrderRows(rows)
}

// AcceptDelivery uses SELECT FOR UPDATE to assign an order to a shipper.
func (r *PostgresOrderRepository) AcceptDelivery(
	orderID, shipperID, shipperName, shipperPhone string,
) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var currentStatus string
	err = tx.QueryRow(`SELECT status FROM orders WHERE id = $1 FOR UPDATE`, orderID).Scan(&currentStatus)
	if err != nil {
		return err
	}

	if currentStatus != "finding_driver" {
		return sql.ErrNoRows // Or custom error
	}

	_, err = tx.Exec(`
		UPDATE orders SET 
			status = 'shipping', 
			shipper_id = $1, shipper_name = $2, shipper_phone = $3, 
			updated_at = NOW()
		WHERE id = $4`, shipperID, shipperName, shipperPhone, orderID)
	if err != nil {
		return err
	}

	return tx.Commit()
}

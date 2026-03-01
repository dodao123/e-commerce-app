// Package repository provides order helper functions.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
)

// scanOrderRows scans rows into order list.
func scanOrderRows(rows *sql.Rows) ([]model.Order, error) {
	var list []model.Order
	for rows.Next() {
		var o model.Order
		if err := rows.Scan(
			&o.ID, &o.UserID,
			&o.ReceiverName, &o.ReceiverPhone,
			&o.Subtotal, &o.ShippingFee, &o.Total,
			&o.Status, &o.Note, &o.CreatedAt,
		); err != nil {
			return nil, err
		}
		list = append(list, o)
	}
	return list, nil
}

// GetDetail returns order + items.
func (r *PostgresOrderRepository) GetDetail(
	orderID string,
) (*model.OrderDetail, error) {
	var o model.Order
	err := r.db.QueryRow(`
		SELECT id, user_id, address_id,
		       receiver_name, receiver_phone, receiver_addr,
		       shipping_method, payment_method,
		       subtotal, shipping_fee, total,
		       status, note, created_at
		FROM orders WHERE id=$1`, orderID).Scan(
		&o.ID, &o.UserID, &o.AddressID,
		&o.ReceiverName, &o.ReceiverPhone,
		&o.ReceiverAddr, &o.ShippingMethod,
		&o.PaymentMethod, &o.Subtotal,
		&o.ShippingFee, &o.Total,
		&o.Status, &o.Note, &o.CreatedAt)
	if err != nil {
		return nil, err
	}
	rows, err := r.db.Query(`
		SELECT id, order_id, product_id, product_name,
		       product_image, price, quantity,
		       shop_id, shop_name
		FROM order_items WHERE order_id=$1`, o.ID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	detail := model.OrderDetail{Order: o}
	for rows.Next() {
		var it model.OrderItem
		if err := rows.Scan(
			&it.ID, &it.OrderID, &it.ProductID,
			&it.ProductName, &it.ProductImage,
			&it.Price, &it.Quantity,
			&it.ShopID, &it.ShopName,
		); err != nil {
			return nil, err
		}
		detail.Items = append(detail.Items, it)
	}
	return &detail, nil
}

// UpdateStatus changes order status.
func (r *PostgresOrderRepository) UpdateStatus(
	orderID, status string,
) error {
	_, err := r.db.Exec(`
		UPDATE orders SET status=$1, updated_at=NOW()
		WHERE id=$2`, status, orderID)
	return err
}

// CountPendingByShop counts pending orders for a shop.
func (r *PostgresOrderRepository) CountPendingByShop(
	shopID string,
) (int, error) {
	var count int
	err := r.db.QueryRow(`
		SELECT COUNT(DISTINCT o.id)
		FROM orders o
		JOIN order_items oi ON oi.order_id = o.id
		WHERE oi.shop_id = $1 AND o.status = 'pending'`,
		shopID).Scan(&count)
	return count, err
}

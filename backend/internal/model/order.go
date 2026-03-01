// Package model defines data structures for database entities.
package model

import "time"

// Order represents a customer order.
type Order struct {
	ID             string    `json:"id"`
	UserID         string    `json:"user_id"`
	AddressID      string    `json:"address_id"`
	ReceiverName   string    `json:"receiver_name"`
	ReceiverPhone  string    `json:"receiver_phone"`
	ReceiverAddr   string    `json:"receiver_addr"`
	ShippingMethod string    `json:"shipping_method"`
	PaymentMethod  string    `json:"payment_method"`
	Subtotal       float64   `json:"subtotal"`
	ShippingFee    float64   `json:"shipping_fee"`
	Total          float64   `json:"total"`
	Status         string    `json:"status"`
	Note           string    `json:"note"`
	CreatedAt      time.Time `json:"created_at"`
}

// OrderItem represents a product in an order.
type OrderItem struct {
	ID           string  `json:"id"`
	OrderID      string  `json:"order_id"`
	ProductID    string  `json:"product_id"`
	ProductName  string  `json:"product_name"`
	ProductImage string  `json:"product_image"`
	Price        float64 `json:"price"`
	Quantity     int     `json:"quantity"`
	ShopID       string  `json:"shop_id"`
	ShopName     string  `json:"shop_name"`
}

// OrderDetail wraps an order with its items.
type OrderDetail struct {
	Order Order       `json:"order"`
	Items []OrderItem `json:"items"`
}

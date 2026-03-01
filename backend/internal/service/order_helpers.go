// Package service provides order helper types and functions.
package service

import (
	"delivery-app/backend/internal/model"
	"fmt"
)

// PlaceOrderRequest contains data for placing an order.
type PlaceOrderRequest struct {
	AddressID      string            `json:"address_id"`
	ShippingMethod string            `json:"shipping_method"`
	PaymentMethod  string            `json:"payment_method"`
	Note           string            `json:"note"`
	Items          []model.OrderItem `json:"items"`
}

// calcSubtotal computes item subtotal.
func calcSubtotal(items []model.OrderItem) float64 {
	var total float64
	for _, it := range items {
		total += it.Price * float64(it.Quantity)
	}
	return total
}

// calcShippingFee returns shipping fee by method.
func calcShippingFee(method string) float64 {
	if method == "fast" {
		return 32700
	}
	return 15000
}

// fmtAddr builds a display address string.
func fmtAddr(addr *model.DeliveryAddress) string {
	return fmt.Sprintf("%s, %s, %s, %s",
		addr.DetailAddress, addr.Ward,
		addr.District, addr.Province)
}

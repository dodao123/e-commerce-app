// Package service provides order business logic.
package service

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
)

// OrderService handles order business logic.
type OrderService struct {
	orderRepo   *repository.PostgresOrderRepository
	addressRepo *repository.PostgresAddressRepository
	cartRepo    *repository.PostgresCartRepository
}

// NewOrderService creates a new OrderService.
func NewOrderService(
	orderRepo *repository.PostgresOrderRepository,
	addressRepo *repository.PostgresAddressRepository,
	cartRepo *repository.PostgresCartRepository,
) *OrderService {
	return &OrderService{
		orderRepo:   orderRepo,
		addressRepo: addressRepo,
		cartRepo:    cartRepo,
	}
}

// PlaceOrder validates and creates a new order.
func (s *OrderService) PlaceOrder(
	userID string, req PlaceOrderRequest,
) (*model.Order, error) {
	if len(req.Items) == 0 {
		return nil, fmt.Errorf("no items in order")
	}
	addr, err := s.addressRepo.GetByID(req.AddressID)
	if err != nil {
		return nil, fmt.Errorf("address not found: %w", err)
	}
	subtotal := calcSubtotal(req.Items)
	fee := calcShippingFee(req.ShippingMethod)
	order := model.Order{
		UserID:         userID,
		AddressID:      req.AddressID,
		ReceiverName:   addr.ReceiverName,
		ReceiverPhone:  addr.Phone,
		ReceiverAddr:   fmtAddr(addr),
		ShippingMethod: req.ShippingMethod,
		PaymentMethod:  req.PaymentMethod,
		Subtotal:       subtotal,
		ShippingFee:    fee,
		Total:          subtotal + fee,
		Status:         "pending",
		Note:           req.Note,
	}
	created, err := s.orderRepo.Create(order, req.Items)
	if err != nil {
		return nil, err
	}
	// Clear cart after ordering
	_ = s.cartRepo.ClearCart(userID)
	return created, nil
}

// ListOrders returns orders for a buyer.
func (s *OrderService) ListOrders(
	userID string,
) ([]model.Order, error) {
	return s.orderRepo.ListByUser(userID)
}

// ListShopOrders returns orders for a seller's shop.
func (s *OrderService) ListShopOrders(
	shopID string,
) ([]model.Order, error) {
	return s.orderRepo.ListByShop(shopID)
}

// GetOrderDetail returns order + items.
func (s *OrderService) GetOrderDetail(
	orderID string,
) (*model.OrderDetail, error) {
	return s.orderRepo.GetDetail(orderID)
}

// UpdateOrderStatus changes order status.
func (s *OrderService) UpdateOrderStatus(
	orderID, status string,
) error {
	return s.orderRepo.UpdateStatus(orderID, status)
}

// CountShopPending returns pending order count.
func (s *OrderService) CountShopPending(
	shopID string,
) (int, error) {
	return s.orderRepo.CountPendingByShop(shopID)
}

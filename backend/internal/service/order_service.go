// Package service provides order business logic.
package service

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
)

// OrderService handles order business logic.
type OrderService struct {
	orderRepo    *repository.PostgresOrderRepository
	addressRepo  *repository.PostgresAddressRepository
	cartRepo     *repository.PostgresCartRepository
	notifService *NotificationService
}

// NewOrderService creates a new OrderService.
func NewOrderService(
	orderRepo *repository.PostgresOrderRepository,
	addressRepo *repository.PostgresAddressRepository,
	cartRepo *repository.PostgresCartRepository,
	notifService *NotificationService,
) *OrderService {
	return &OrderService{
		orderRepo:    orderRepo,
		addressRepo:  addressRepo,
		cartRepo:     cartRepo,
		notifService: notifService,
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
	// Notify seller(s)
	if s.notifService != nil {
		go s.notifService.CreateOrderNotification(
			created, req.Items)
	}
	return created, nil
}

// ListOrders returns orders for a buyer.
func (s *OrderService) ListOrders(
	userID string,
) ([]model.Order, error) {
	orders, err := s.orderRepo.ListByUser(userID)
	if err != nil {
		return nil, err
	}
	for i := range orders {
		detail, _ := s.orderRepo.GetDetail(orders[i].ID)
		if detail != nil {
			orders[i].Items = detail.Items
		}
	}
	return orders, nil
}

// ListShopOrders returns orders for a seller's shop.
func (s *OrderService) ListShopOrders(
	shopID string,
) ([]model.Order, error) {
	orders, err := s.orderRepo.ListByShop(shopID)
	if err != nil {
		return nil, err
	}
	for i := range orders {
		detail, _ := s.orderRepo.GetDetail(orders[i].ID)
		if detail != nil {
			orders[i].Items = detail.Items
		}
	}
	return orders, nil
}

// ListDriverOrders returns orders assigned to a driver.
func (s *OrderService) ListDriverOrders(
	driverID string,
) ([]model.Order, error) {
	orders, err := s.orderRepo.ListByShipper(driverID)
	if err != nil {
		return nil, err
	}
	for i := range orders {
		detail, _ := s.orderRepo.GetDetail(orders[i].ID)
		if detail != nil {
			orders[i].Items = detail.Items
		}
	}
	return orders, nil
}

// GetOrderDetail returns order + items.
func (s *OrderService) GetOrderDetail(
	orderID string,
) (*model.OrderDetail, error) {
	return s.orderRepo.GetDetail(orderID)
}

// UpdateOrderStatus changes order status and notifies all relevant parties.
func (s *OrderService) UpdateOrderStatus(
	orderID, status string,
) error {
	err := s.orderRepo.UpdateStatus(orderID, status)
	if err != nil {
		return err
	}
	if s.notifService == nil {
		return nil
	}
	detail, _ := s.orderRepo.GetDetail(orderID)
	if detail == nil {
		return nil
	}
	switch status {
	case "finding_driver":
		// Seller confirmed → notify all drivers
		_ = s.notifService.NotifyAllDrivers(&detail.Order)
	case "delivered":
		// Driver delivered → notify buyer + seller
		s.notifService.NotifyOrderDelivered(
			&detail.Order, detail.Items)
	}
	return nil
}

// AcceptOrderDelivery handles a driver accepting an order.
func (s *OrderService) AcceptOrderDelivery(
	orderID, driverID, driverName, driverPhone string,
) error {
	err := s.orderRepo.AcceptDelivery(orderID, driverID, driverName, driverPhone)
	if err != nil {
		return err
	}
	// Notify Shop and Buyer
	if s.notifService != nil {
		detail, _ := s.orderRepo.GetDetail(orderID)
		if detail != nil {
			s.notifService.NotifyOrderAccepted(&detail.Order, detail.Items, driverName)
		}
	}
	return nil
}

// CountShopPending returns pending order count.
func (s *OrderService) CountShopPending(
	shopID string,
) (int, error) {
	return s.orderRepo.CountPendingByShop(shopID)
}

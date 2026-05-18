// Package service provides order notification push logic.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"fmt"
)

// CreateOrderNotification notifies shop owner(s) when a new order is placed.
func (s *NotificationService) CreateOrderNotification(
	order *model.Order, items []model.OrderItem,
) {
	seen := map[string]bool{}
	for _, it := range items {
		if it.ShopID == "" || seen[it.ShopID] {
			continue
		}
		seen[it.ShopID] = true
		shop, err := s.shopRepo.GetShopByID(
			context.Background(), it.ShopID)
		if err != nil || shop == nil {
			continue
		}
		title := "🛍️ Đơn hàng mới!"
		body := fmt.Sprintf("Bạn có đơn hàng từ %s — %s",
			order.ReceiverName, it.ProductName)
		s.dbAndPush(model.Notification{
			UserID:     shop.SellerID,
			Title:      title,
			Body:       body,
			Type:       "order",
			TargetRole: "seller",
			RefID:      order.ID,
		}, title, body)
	}
}

// NotifyAllDrivers notifies all drivers via DB + FCM push.
func (s *NotificationService) NotifyAllDrivers(
	order *model.Order,
) error {
	if err := s.notifRepo.NotifyAllDrivers(order); err != nil {
		return err
	}
	if s.tokenRepo != nil {
		tokens, err := s.tokenRepo.GetDriverTokens()
		if err == nil && len(tokens) > 0 {
			globalFcm.SendToMultiple(
				tokens,
				"🚚 Có đơn hàng cần giao!",
				fmt.Sprintf("Đơn hàng từ %s đang chờ tài xế nhận",
					order.ReceiverName),
			)
		}
	}
	return nil
}

// NotifyOrderAccepted notifies buyer and shop(s) when a driver accepts.
func (s *NotificationService) NotifyOrderAccepted(
	order *model.Order, items []model.OrderItem,
	driverName string,
) {
	buyerTitle := "🚗 Đơn hàng đang được giao!"
	buyerBody := fmt.Sprintf(
		"Tài xế %s đã nhận và đang giao đơn hàng của bạn.",
		driverName)
	s.dbAndPush(model.Notification{
		UserID: order.UserID, Title: buyerTitle,
		Body: buyerBody, Type: "order",
		TargetRole: "buyer", RefID: order.ID,
	}, buyerTitle, buyerBody)

	s.notifyShops(order, items, "✅ Tài xế đã nhận đơn!",
		func(it model.OrderItem) string {
			return fmt.Sprintf(
				"Tài Xế %s đến lấy hàng - Sản Phẩm %s - của khách hàng %s",
				driverName, it.ProductName, order.ReceiverName)
		})
}

// NotifyOrderDelivered notifies buyer and seller(s) when delivered.
func (s *NotificationService) NotifyOrderDelivered(
	order *model.Order, items []model.OrderItem,
) {
	buyerTitle := "🎉 Giao hàng thành công!"
	buyerBody := "Đơn hàng của bạn đã được giao thành công. Cảm ơn bạn!"
	s.dbAndPush(model.Notification{
		UserID: order.UserID, Title: buyerTitle,
		Body: buyerBody, Type: "order",
		TargetRole: "buyer", RefID: order.ID,
	}, buyerTitle, buyerBody)

	s.notifyShops(order, items, "📦 Đơn hàng đã giao!",
		func(it model.OrderItem) string {
			return fmt.Sprintf(
				"Sản phẩm %s đã được giao thành công.", it.ProductName)
		})
}

// NotifyOrderCancelled notifies seller(s) when buyer cancels.
func (s *NotificationService) NotifyOrderCancelled(
	order *model.Order, items []model.OrderItem,
) {
	s.notifyShops(order, items, "❌ Đơn hàng bị hủy!",
		func(it model.OrderItem) string {
			return fmt.Sprintf(
				"Khách hàng %s đã hủy đơn hàng — %s",
				order.ReceiverName, it.ProductName)
		})
}

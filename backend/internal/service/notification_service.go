// Package service handles notification business logic with FCM push support.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
	"log"
)

// NotificationService handles notification operations.
type NotificationService struct {
	notifRepo  *repository.PostgresNotificationRepository
	shopRepo   *repository.PostgresShopRepository
	tokenRepo  *repository.PostgresFcmTokenRepository
}

// NewNotificationService creates a new service.
func NewNotificationService(
	notifRepo *repository.PostgresNotificationRepository,
	shopRepo *repository.PostgresShopRepository,
	tokenRepo *repository.PostgresFcmTokenRepository,
) *NotificationService {
	return &NotificationService{
		notifRepo: notifRepo,
		shopRepo:  shopRepo,
		tokenRepo: tokenRepo,
	}
}

// pushToUser sends FCM push to a specific user and logs any error.
func (s *NotificationService) pushToUser(
	userID, title, body string,
) {
	if s.tokenRepo == nil {
		return
	}
	token, err := s.tokenRepo.GetByUserID(userID)
	if err != nil || token == "" {
		return
	}
	go globalFcm.SendToToken(token, title, body) //nolint:errcheck
}

// dbAndPush creates a DB notification and sends an FCM push.
func (s *NotificationService) dbAndPush(n model.Notification, title, body string) {
	if err := s.notifRepo.Create(n); err != nil {
		log.Printf("⚠️ Create notif err: %v", err)
	}
	s.pushToUser(n.UserID, title, body)
}

// CreateOrderNotification notifies shop owner(s) when a new order is placed.
// Also sends FCM push to the seller's device immediately.
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
			log.Printf("⚠️ Shop not found: %s", it.ShopID)
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

// NotifyAllDrivers notifies all drivers about a new order via DB + FCM push.
func (s *NotificationService) NotifyAllDrivers(order *model.Order) error {
	if err := s.notifRepo.NotifyAllDrivers(order); err != nil {
		return err
	}
	// FCM push to all driver devices immediately
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
	order *model.Order, items []model.OrderItem, driverName string,
) {
	// 1. Notify buyer
	buyerTitle := "🚗 Đơn hàng đang được giao!"
	buyerBody := fmt.Sprintf(
		"Tài xế %s đã nhận và đang giao đơn hàng của bạn.", driverName)
	s.dbAndPush(model.Notification{
		UserID:     order.UserID,
		Title:      buyerTitle,
		Body:       buyerBody,
		Type:       "order",
		TargetRole: "buyer",
		RefID:      order.ID,
	}, buyerTitle, buyerBody)

	// 2. Notify shop(s)
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
		sellerTitle := "✅ Tài xế đã nhận đơn!"
		sellerBody := fmt.Sprintf(
			"Tài Xế %s đến lấy hàng - Sản Phẩm %s - của khách hàng %s",
			driverName, it.ProductName, order.ReceiverName)
		s.dbAndPush(model.Notification{
			UserID:     shop.SellerID,
			Title:      sellerTitle,
			Body:       sellerBody,
			Type:       "order",
			TargetRole: "seller",
			RefID:      order.ID,
		}, sellerTitle, sellerBody)
	}
}

// NotifyOrderDelivered notifies buyer (and seller) when delivered.
func (s *NotificationService) NotifyOrderDelivered(
	order *model.Order, items []model.OrderItem,
) {
	// 1. Notify buyer
	buyerTitle := "🎉 Giao hàng thành công!"
	buyerBody := "Đơn hàng của bạn đã được giao thành công. Cảm ơn bạn!"
	s.dbAndPush(model.Notification{
		UserID:     order.UserID,
		Title:      buyerTitle,
		Body:       buyerBody,
		Type:       "order",
		TargetRole: "buyer",
		RefID:      order.ID,
	}, buyerTitle, buyerBody)

	// 2. Notify shop(s)
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
		sellerTitle := "📦 Đơn hàng đã giao!"
		sellerBody := fmt.Sprintf(
			"Sản phẩm %s đã được giao thành công.", it.ProductName)
		s.dbAndPush(model.Notification{
			UserID:     shop.SellerID,
			Title:      sellerTitle,
			Body:       sellerBody,
			Type:       "order",
			TargetRole: "seller",
			RefID:      order.ID,
		}, sellerTitle, sellerBody)
	}
}
// NotifyOrderCancelled notifies seller(s) when buyer cancels.
func (s *NotificationService) NotifyOrderCancelled(
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
		title := "❌ Đơn hàng bị hủy!"
		body := fmt.Sprintf(
			"Khách hàng %s đã hủy đơn hàng — %s",
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

// ListByUser returns notifications for a user.
func (s *NotificationService) ListByUser(
	userID string, role string,
) ([]model.Notification, error) {
	return s.notifRepo.ListByUser(userID, role)
}

// MarkRead marks a notification as read.
func (s *NotificationService) MarkRead(
	notifID string,
) error {
	return s.notifRepo.MarkRead(notifID)
}

// CountUnread returns unread notification count.
func (s *NotificationService) CountUnread(
	userID string, role string,
) (int, error) {
	return s.notifRepo.CountUnread(userID, role)
}

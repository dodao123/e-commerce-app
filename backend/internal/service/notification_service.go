// Package service provides notification business logic.
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
	notifRepo *repository.PostgresNotificationRepository
	shopRepo  *repository.PostgresShopRepository
}

// NewNotificationService creates a new service.
func NewNotificationService(
	notifRepo *repository.PostgresNotificationRepository,
	shopRepo *repository.PostgresShopRepository,
) *NotificationService {
	return &NotificationService{
		notifRepo: notifRepo, shopRepo: shopRepo,
	}
}

// CreateOrderNotification creates notifications for
// each shop owner involved in the order.
func (s *NotificationService) CreateOrderNotification(
	order *model.Order, items []model.OrderItem,
) {
	// Collect unique shop IDs
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
		notif := model.Notification{
			UserID: shop.SellerID,
			Title:  "Đơn hàng mới!",
			Body: fmt.Sprintf(
				"Bạn có đơn hàng mới từ %s — %s",
				order.ReceiverName, it.ProductName),
			Type:  "order",
			RefID: order.ID,
		}
		if err := s.notifRepo.Create(notif); err != nil {
			log.Printf("⚠️ Create notif err: %v", err)
		}
	}
}

// ListByUser returns notifications for a user.
func (s *NotificationService) ListByUser(
	userID string,
) ([]model.Notification, error) {
	return s.notifRepo.ListByUser(userID)
}

// MarkRead marks a notification as read.
func (s *NotificationService) MarkRead(
	notifID string,
) error {
	return s.notifRepo.MarkRead(notifID)
}

// CountUnread returns unread notification count.
func (s *NotificationService) CountUnread(
	userID string,
) (int, error) {
	return s.notifRepo.CountUnread(userID)
}

// Package service handles notification business logic with FCM push support.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"log"
)

// NotificationService handles notification operations.
type NotificationService struct {
	notifRepo *repository.PostgresNotificationRepository
	shopRepo  *repository.PostgresShopRepository
	tokenRepo *repository.PostgresFcmTokenRepository
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

// pushToUser sends FCM push to a specific user.
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
func (s *NotificationService) dbAndPush(
	n model.Notification, title, body string,
) {
	if err := s.notifRepo.Create(n); err != nil {
		log.Printf("⚠️ Create notif err: %v", err)
	}
	s.pushToUser(n.UserID, title, body)
}

// notifyShops sends notifications to all unique shop owners in items.
func (s *NotificationService) notifyShops(
	order *model.Order, items []model.OrderItem,
	title string, bodyFn func(model.OrderItem) string,
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
		body := bodyFn(it)
		s.dbAndPush(model.Notification{
			UserID: shop.SellerID, Title: title,
			Body: body, Type: "order",
			TargetRole: "seller", RefID: order.ID,
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

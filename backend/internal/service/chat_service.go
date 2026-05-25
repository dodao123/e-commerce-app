package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
)

// ChatService coordinates chat rooms and messages operations.
type ChatService struct {
	chatRepo repository.ChatRepository
	shopRepo repository.ShopRepository
}

// NewChatService creates a new instance of ChatService.
func NewChatService(chatRepo repository.ChatRepository, shopRepo repository.ShopRepository) *ChatService {
	return &ChatService{chatRepo: chatRepo, shopRepo: shopRepo}
}

// GetOrCreateRoom finds or creates a persistent continuous chat room.
func (s *ChatService) GetOrCreateRoom(ctx context.Context, userID string, req *model.CreateChatRoomRequest) (*model.ChatRoom, error) {
	var customerID, shopID, shipperID *string

	switch req.RoomType {
	case "customer_shop":
		customerID = &userID
		shopID = req.ShopID
	case "shipper_customer":
		shipperID = &userID
		customerID = req.ShopID // Frontend can pass customer ID in ShopID slot for shipper_customer
	case "shipper_shop":
		shipperID = &userID
		shopID = req.ShopID
	default:
		return nil, fmt.Errorf("invalid room type: %s", req.RoomType)
	}

	// Search for existing room first to ensure continuity
	existing, err := s.chatRepo.FindRoomByParticipants(ctx, req.RoomType, customerID, shopID, shipperID)
	if err == nil && existing != nil {
		return s.chatRepo.GetRoomWithDetails(ctx, existing.ID, userID)
	}

	room := &model.ChatRoom{
		RoomType:          req.RoomType,
		CustomerID:        customerID,
		ShopID:            shopID,
		ShipperID:         shipperID,
		AssociatedOrderID: req.AssociatedOrderID,
	}

	if err := s.chatRepo.CreateRoom(ctx, room); err != nil {
		return nil, err
	}
	return s.chatRepo.GetRoomWithDetails(ctx, room.ID, userID)
}

// GetRoomByID retrieves a room by its ID.
func (s *ChatService) GetRoomByID(ctx context.Context, roomID string) (*model.ChatRoom, error) {
	return s.chatRepo.GetRoomByID(ctx, roomID)
}

// SendMessage saves a message in a room and triggers auto-replies if applicable.
func (s *ChatService) SendMessage(ctx context.Context, senderID string, senderRole string, roomID string, content string, msgType string) (*model.ChatMessage, error) {
	msg := &model.ChatMessage{
		RoomID:      roomID,
		SenderID:    senderID,
		SenderRole:  senderRole,
		MessageType: msgType,
		Content:     content,
		IsRead:      false,
	}

	if err := s.chatRepo.CreateMessage(ctx, msg); err != nil {
		return nil, err
	}
	return msg, nil
}

// ListRooms returns the active rooms list for either user or shop.
func (s *ChatService) ListRooms(ctx context.Context, userID string, role string) ([]*model.ChatRoom, error) {
	if role == "seller" {
		shop, err := s.shopRepo.GetShopBySellerID(ctx, userID)
		if err != nil || shop == nil {
			return nil, fmt.Errorf("shop not found for seller")
		}
		return s.chatRepo.ListRoomsForShop(ctx, shop.ID)
	}
	return s.chatRepo.ListRoomsForUser(ctx, userID)
}

// ListMessages returns list of messages inside a room.
func (s *ChatService) ListMessages(ctx context.Context, roomID string, limit, offset int) ([]*model.ChatMessage, error) {
	return s.chatRepo.ListMessagesInRoom(ctx, roomID, limit, offset)
}

// MarkAsRead marks all other participant messages in room as read.
func (s *ChatService) MarkAsRead(ctx context.Context, roomID string, userID string) error {
	return s.chatRepo.MarkMessagesAsRead(ctx, roomID, userID)
}

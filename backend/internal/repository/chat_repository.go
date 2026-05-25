package repository

import (
	"context"
	"delivery-app/backend/internal/model"
)

// ChatRepository defines the methods to persist and retrieve chat data.
type ChatRepository interface {
	// CreateRoom creates a new chat room.
	CreateRoom(ctx context.Context, room *model.ChatRoom) error

	// GetRoomByID retrieves a chat room by its ID.
	GetRoomByID(ctx context.Context, roomID string) (*model.ChatRoom, error)

	// GetRoomWithDetails retrieves a chat room with populated PartnerName and PartnerAvatar.
	GetRoomWithDetails(ctx context.Context, roomID string, userID string) (*model.ChatRoom, error)

	// FindRoomByParticipants finds a room matching the active participant context.
	FindRoomByParticipants(ctx context.Context, roomType string, customerID, shopID, shipperID *string) (*model.ChatRoom, error)

	// ListRoomsForUser lists active chat rooms for a user (customer or shipper).
	ListRoomsForUser(ctx context.Context, userID string) ([]*model.ChatRoom, error)

	// ListRoomsForShop lists active chat rooms for a shop.
	ListRoomsForShop(ctx context.Context, shopID string) ([]*model.ChatRoom, error)

	// CreateMessage saves a new chat message to a room.
	CreateMessage(ctx context.Context, message *model.ChatMessage) error

	// ListMessagesInRoom retrieves page of messages in a room.
	ListMessagesInRoom(ctx context.Context, roomID string, limit, offset int) ([]*model.ChatMessage, error)

	// MarkMessagesAsRead updates messages to read state.
	MarkMessagesAsRead(ctx context.Context, roomID string, userID string) error
}

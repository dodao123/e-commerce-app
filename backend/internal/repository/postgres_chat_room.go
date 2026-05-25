package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// PostgresChatRepository implements ChatRepository using PostgreSQL.
type PostgresChatRepository struct {
	database *sql.DB
}

// NewPostgresChatRepository creates a new instance of PostgresChatRepository.
func NewPostgresChatRepository(database *sql.DB) *PostgresChatRepository {
	return &PostgresChatRepository{database: database}
}

// CreateRoom inserts a new chat room into the database.
func (repo *PostgresChatRepository) CreateRoom(ctx context.Context, room *model.ChatRoom) error {
	query := `
		INSERT INTO chat_rooms (id, room_type, customer_id, shop_id, shipper_id, associated_order_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	room.ID = uuid.New().String()
	now := time.Now()
	room.CreatedAt = now
	room.UpdatedAt = now

	_, err := repo.database.ExecContext(ctx, query,
		room.ID, room.RoomType, room.CustomerID, room.ShopID, room.ShipperID, room.AssociatedOrderID,
		room.CreatedAt, room.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create chat room: %w", err)
	}
	return nil
}

// GetRoomByID retrieves a chat room by its ID.
func (repo *PostgresChatRepository) GetRoomByID(ctx context.Context, roomID string) (*model.ChatRoom, error) {
	query := `
		SELECT id, room_type, customer_id, shop_id, shipper_id, associated_order_id, created_at, updated_at
		FROM chat_rooms WHERE id = $1
	`
	room := &model.ChatRoom{}
	err := repo.database.QueryRowContext(ctx, query, roomID).Scan(
		&room.ID, &room.RoomType, &room.CustomerID, &room.ShopID, &room.ShipperID, &room.AssociatedOrderID,
		&room.CreatedAt, &room.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("chat room not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get chat room: %w", err)
	}
	return room, nil
}

// FindRoomByParticipants checks if a room already exists for these participants.
func (repo *PostgresChatRepository) FindRoomByParticipants(
	ctx context.Context, roomType string, customerID, shopID, shipperID *string,
) (*model.ChatRoom, error) {
	query := `
		SELECT id, room_type, customer_id, shop_id, shipper_id, associated_order_id, created_at, updated_at
		FROM chat_rooms
		WHERE room_type = $1
		  AND (customer_id = $2 OR (customer_id IS NULL AND $2 IS NULL))
		  AND (shop_id = $3 OR (shop_id IS NULL AND $3 IS NULL))
		  AND (shipper_id = $4 OR (shipper_id IS NULL AND $4 IS NULL))
		LIMIT 1
	`
	room := &model.ChatRoom{}
	err := repo.database.QueryRowContext(ctx, query, roomType, customerID, shopID, shipperID).Scan(
		&room.ID, &room.RoomType, &room.CustomerID, &room.ShopID, &room.ShipperID, &room.AssociatedOrderID,
		&room.CreatedAt, &room.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to find chat room: %w", err)
	}
	return room, nil
}

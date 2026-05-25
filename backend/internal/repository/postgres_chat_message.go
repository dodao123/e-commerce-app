package repository

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
)

// ListRoomsForUser retrieves active rooms for a customer or shipper.
func (repo *PostgresChatRepository) ListRoomsForUser(ctx context.Context, userID string) ([]*model.ChatRoom, error) {
	query := `
		SELECT r.id, r.room_type, r.customer_id, r.shop_id, r.shipper_id, r.associated_order_id, r.created_at, r.updated_at,
		       COALESCE(s.shop_name, u.full_name, '') as partner_name,
		       COALESCE(seller.avatar_url, u.avatar_url, '') as partner_avatar,
		       COALESCE((SELECT content FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_message,
		       COALESCE((SELECT message_type FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), 'text') as last_msg_type,
		       COALESCE((SELECT sender_id::text FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_msg_sender_id,
		       (SELECT COUNT(*) FROM chat_messages WHERE room_id = r.id AND sender_id != $1 AND is_read = false) as unread_count
		FROM chat_rooms r
		LEFT JOIN shops s ON r.shop_id = s.id AND r.room_type = 'customer_shop'
		LEFT JOIN users seller ON s.seller_id = seller.id AND r.room_type = 'customer_shop'
		LEFT JOIN users u ON (u.id = r.shipper_id AND r.room_type = 'shipper_customer') 
		                  OR (u.id = r.customer_id AND r.room_type = 'shipper_customer')
		WHERE (r.customer_id = $1 OR r.shipper_id = $1)
		  AND EXISTS (SELECT 1 FROM chat_messages WHERE room_id = r.id)
		ORDER BY r.updated_at DESC
	`
	rows, err := repo.database.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to list rooms for user: %w", err)
	}
	defer rows.Close()

	var rooms []*model.ChatRoom
	for rows.Next() {
		r := &model.ChatRoom{}
		var lastMsgType, lastMsgSenderID string
		err := rows.Scan(
			&r.ID, &r.RoomType, &r.CustomerID, &r.ShopID, &r.ShipperID, &r.AssociatedOrderID, &r.CreatedAt, &r.UpdatedAt,
			&r.PartnerName, &r.PartnerAvatar, &r.LastMessage, &lastMsgType, &lastMsgSenderID, &r.UnreadCount,
		)
		if err != nil {
			return nil, err
		}

		if lastMsgType == "image" {
			if lastMsgSenderID == userID {
				r.LastMessage = "Bạn đã gửi một hình ảnh"
			} else {
				r.LastMessage = fmt.Sprintf("%s đã gửi một hình ảnh", r.PartnerName)
			}
		} else if lastMsgType == "sticker" {
			if lastMsgSenderID == userID {
				r.LastMessage = "Bạn đã gửi một nhãn dán"
			} else {
				r.LastMessage = fmt.Sprintf("%s đã gửi một nhãn dán", r.PartnerName)
			}
		}

		// Fallback to local shop logo if avatar is not a Google avatar
		if r.RoomType == "customer_shop" && r.ShopID != nil && *r.ShopID != "" {
			isGoogleAvatar := strings.Contains(r.PartnerAvatar, "googleusercontent") || strings.Contains(r.PartnerAvatar, "google")
			if !isGoogleAvatar || r.PartnerAvatar == "" {
				logoPath := filepath.Join("uploads", "logos", fmt.Sprintf("shop_%s.png", *r.ShopID))
				if _, err := os.Stat(logoPath); err == nil {
					r.PartnerAvatar = fmt.Sprintf("/uploads/logos/shop_%s.png", *r.ShopID)
				}
			}
		}

		rooms = append(rooms, r)
	}
	return rooms, nil
}

// ListRoomsForShop retrieves active rooms for a shop.
func (repo *PostgresChatRepository) ListRoomsForShop(ctx context.Context, shopID string) ([]*model.ChatRoom, error) {
	query := `
		SELECT r.id, r.room_type, r.customer_id, r.shop_id, r.shipper_id, r.associated_order_id, r.created_at, r.updated_at,
		       COALESCE(u.full_name, '') as partner_name,
		       COALESCE(u.avatar_url, '') as partner_avatar,
		       COALESCE((SELECT content FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_message,
		       COALESCE((SELECT message_type FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), 'text') as last_msg_type,
		       COALESCE((SELECT sender_id::text FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_msg_sender_id,
		       (SELECT COUNT(*) FROM chat_messages WHERE room_id = r.id AND sender_id != $1 AND is_read = false) as unread_count
		FROM chat_rooms r
		LEFT JOIN users u ON u.id = r.customer_id OR u.id = r.shipper_id
		WHERE r.shop_id = $1
		  AND EXISTS (SELECT 1 FROM chat_messages WHERE room_id = r.id)
		ORDER BY r.updated_at DESC
	`
	rows, err := repo.database.QueryContext(ctx, query, shopID)
	if err != nil {
		return nil, fmt.Errorf("failed to list rooms for shop: %w", err)
	}
	defer rows.Close()

	var rooms []*model.ChatRoom
	for rows.Next() {
		r := &model.ChatRoom{}
		var lastMsgType, lastMsgSenderID string
		err := rows.Scan(
			&r.ID, &r.RoomType, &r.CustomerID, &r.ShopID, &r.ShipperID, &r.AssociatedOrderID, &r.CreatedAt, &r.UpdatedAt,
			&r.PartnerName, &r.PartnerAvatar, &r.LastMessage, &lastMsgType, &lastMsgSenderID, &r.UnreadCount,
		)
		if err != nil {
			return nil, err
		}

		if lastMsgType == "image" {
			if (r.CustomerID == nil || lastMsgSenderID != *r.CustomerID) && (r.ShipperID == nil || lastMsgSenderID != *r.ShipperID) {
				r.LastMessage = "Bạn đã gửi một hình ảnh"
			} else {
				r.LastMessage = fmt.Sprintf("%s đã gửi một hình ảnh", r.PartnerName)
			}
		} else if lastMsgType == "sticker" {
			if (r.CustomerID == nil || lastMsgSenderID != *r.CustomerID) && (r.ShipperID == nil || lastMsgSenderID != *r.ShipperID) {
				r.LastMessage = "Bạn đã gửi một nhãn dán"
			} else {
				r.LastMessage = fmt.Sprintf("%s đã gửi một nhãn dán", r.PartnerName)
			}
		}

		rooms = append(rooms, r)
	}
	return rooms, nil
}

// CreateMessage inserts a message and updates the room's updated_at timestamp.
func (repo *PostgresChatRepository) CreateMessage(ctx context.Context, message *model.ChatMessage) error {
	tx, err := repo.database.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	message.ID = uuid.New().String()
	message.CreatedAt = time.Now()

	msgQuery := `
		INSERT INTO chat_messages (id, room_id, sender_id, sender_role, message_type, content, is_read, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	_, err = tx.ExecContext(ctx, msgQuery,
		message.ID, message.RoomID, message.SenderID, message.SenderRole, message.MessageType,
		message.Content, message.IsRead, message.CreatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to insert message: %w", err)
	}

	roomQuery := `UPDATE chat_rooms SET updated_at = $1 WHERE id = $2`
	_, err = tx.ExecContext(ctx, roomQuery, message.CreatedAt, message.RoomID)
	if err != nil {
		return fmt.Errorf("failed to update chat room timestamp: %w", err)
	}

	// 1. Fetch room details
	var roomType string
	var customerID, shopID, shipperID sql.NullString
	err = tx.QueryRowContext(ctx, `
		SELECT room_type, customer_id, shop_id, shipper_id 
		FROM chat_rooms WHERE id = $1
	`, message.RoomID).Scan(&roomType, &customerID, &shopID, &shipperID)
	if err != nil {
		return fmt.Errorf("failed to fetch chat room details for notification: %w", err)
	}

	// 2. Identify recipient
	var recipientID string
	var recipientRole string

	switch roomType {
	case "customer_shop":
		if message.SenderRole == "customer" || message.SenderRole == "buyer" {
			err = tx.QueryRowContext(ctx, "SELECT seller_id FROM shops WHERE id = $1", shopID.String).Scan(&recipientID)
			if err == nil {
				recipientRole = "seller"
			}
		} else {
			recipientID = customerID.String
			recipientRole = "buyer"
		}
	case "shipper_customer":
		if message.SenderRole == "shipper" {
			recipientID = customerID.String
			recipientRole = "buyer"
		} else {
			recipientID = shipperID.String
			recipientRole = "driver"
		}
	case "shipper_shop":
		if message.SenderRole == "shipper" {
			err = tx.QueryRowContext(ctx, "SELECT seller_id FROM shops WHERE id = $1", shopID.String).Scan(&recipientID)
			if err == nil {
				recipientRole = "seller"
			}
		} else {
			recipientID = shipperID.String
			recipientRole = "driver"
		}
	}

	if recipientID != "" && recipientRole != "" {
		if _, err := uuid.Parse(recipientID); err != nil {
			log.Printf("[CreateMessage] Skipping invalid recipientID UUID '%s': %v", recipientID, err)
			return tx.Commit()
		}

		// Determine notification title based on sender name
		var senderName string
		var errQuery error
		if message.SenderRole == "customer" || message.SenderRole == "buyer" || message.SenderRole == "shipper" {
			errQuery = tx.QueryRowContext(ctx, "SELECT full_name FROM users WHERE id = $1", message.SenderID).Scan(&senderName)
		} else {
			errQuery = tx.QueryRowContext(ctx, "SELECT s.shop_name FROM shops s WHERE s.seller_id = $1", message.SenderID).Scan(&senderName)
		}
		if errQuery != nil && errQuery != sql.ErrNoRows {
			log.Printf("[CreateMessage] Scan senderName error: %v", errQuery)
			return errQuery
		}
		if senderName == "" {
			senderName = "Bạn mới"
		}

		title := fmt.Sprintf("Tin nhắn mới từ %s", senderName)
		body := message.Content
		if message.MessageType == "sticker" || strings.Contains(message.Content, "sticker") {
			body = fmt.Sprintf("%s đã gửi bạn 1 sticker", senderName)
		} else if message.MessageType == "image" || strings.Contains(message.Content, "uploads/") {
			body = fmt.Sprintf("%s đã gửi bạn 1 ảnh", senderName)
		}

		runes := []rune(body)
		if len(runes) > 60 {
			body = string(runes[:57]) + "..."
		}

		_, errNotif := tx.ExecContext(ctx, `
			INSERT INTO notifications (user_id, title, body, type, target_role, ref_id, is_read)
			VALUES ($1, $2, $3, 'chat', $4, $5, false)
		`, recipientID, title, body, recipientRole, message.RoomID)
		if errNotif != nil {
			log.Printf("[CreateMessage] Insert notification error: %v", errNotif)
			return errNotif
		}
	}

	return tx.Commit()
}

// ListMessagesInRoom retrieves page of messages in a room.
func (repo *PostgresChatRepository) ListMessagesInRoom(ctx context.Context, roomID string, limit, offset int) ([]*model.ChatMessage, error) {
	query := `
		SELECT id, room_id, sender_id, sender_role, message_type, content, is_read, created_at
		FROM chat_messages
		WHERE room_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := repo.database.QueryContext(ctx, query, roomID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list messages: %w", err)
	}
	defer rows.Close()

	var messages []*model.ChatMessage
	for rows.Next() {
		m := &model.ChatMessage{}
		err := rows.Scan(
			&m.ID, &m.RoomID, &m.SenderID, &m.SenderRole, &m.MessageType, &m.Content, &m.IsRead, &m.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		messages = append(messages, m)
	}
	return messages, nil
}

// MarkMessagesAsRead updates all unread messages sent by others in this room to read.
func (repo *PostgresChatRepository) MarkMessagesAsRead(ctx context.Context, roomID string, userID string) error {
	query := `
		UPDATE chat_messages
		SET is_read = true
		WHERE room_id = $1 AND sender_id != $2 AND is_read = false
	`
	_, err := repo.database.ExecContext(ctx, query, roomID, userID)
	if err != nil {
		return fmt.Errorf("failed to mark messages as read: %w", err)
	}
	return nil
}

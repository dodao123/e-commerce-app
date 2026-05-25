package repository

import (
	"context"
	"delivery-app/backend/internal/model"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// GetRoomWithDetails retrieves a chat room with populated PartnerName and PartnerAvatar.
func (repo *PostgresChatRepository) GetRoomWithDetails(ctx context.Context, roomID string, userID string) (*model.ChatRoom, error) {
	query := `
		SELECT r.id, r.room_type, r.customer_id, r.shop_id, r.shipper_id, r.associated_order_id, r.created_at, r.updated_at,
		       CASE 
		           WHEN r.room_type = 'customer_shop' THEN
		               CASE WHEN r.customer_id = $2 THEN s.shop_name ELSE customer_user.full_name END
		           WHEN r.room_type = 'shipper_customer' THEN
		               CASE WHEN r.customer_id = $2 THEN shipper_user.full_name ELSE customer_user.full_name END
		           WHEN r.room_type = 'shipper_shop' THEN
		               CASE WHEN r.shipper_id = $2 THEN s.shop_name ELSE shipper_user.full_name END
		           ELSE ''
		       END as partner_name,
		       CASE 
		           WHEN r.room_type = 'customer_shop' THEN
		               CASE WHEN r.customer_id = $2 THEN COALESCE(seller.avatar_url, '') ELSE COALESCE(customer_user.avatar_url, '') END
		           WHEN r.room_type = 'shipper_customer' THEN
		               CASE WHEN r.customer_id = $2 THEN COALESCE(shipper_user.avatar_url, '') ELSE COALESCE(customer_user.avatar_url, '') END
		           WHEN r.room_type = 'shipper_shop' THEN
		               CASE WHEN r.shipper_id = $2 THEN COALESCE(seller.avatar_url, '') ELSE COALESCE(shipper_user.avatar_url, '') END
		           ELSE ''
		       END as partner_avatar
		FROM chat_rooms r
		LEFT JOIN shops s ON r.shop_id = s.id
		LEFT JOIN users seller ON s.seller_id = seller.id
		LEFT JOIN users customer_user ON r.customer_id = customer_user.id
		LEFT JOIN users shipper_user ON r.shipper_id = shipper_user.id
		WHERE r.id = $1
	`
	room := &model.ChatRoom{}
	err := repo.database.QueryRowContext(ctx, query, roomID, userID).Scan(
		&room.ID, &room.RoomType, &room.CustomerID, &room.ShopID, &room.ShipperID, &room.AssociatedOrderID,
		&room.CreatedAt, &room.UpdatedAt, &room.PartnerName, &room.PartnerAvatar,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get room with details: %w", err)
	}

	// Fallback to local shop logo if avatar is not a Google avatar
	if room.RoomType == "customer_shop" && room.ShopID != nil && *room.ShopID != "" && room.CustomerID != nil && *room.CustomerID == userID {
		isGoogleAvatar := strings.Contains(room.PartnerAvatar, "googleusercontent") || strings.Contains(room.PartnerAvatar, "google")
		if !isGoogleAvatar || room.PartnerAvatar == "" {
			logoPath := filepath.Join("uploads", "logos", fmt.Sprintf("shop_%s.png", *room.ShopID))
			if _, err := os.Stat(logoPath); err == nil {
				room.PartnerAvatar = fmt.Sprintf("/uploads/logos/shop_%s.png", *room.ShopID)
			}
		}
	}

	return room, nil
}

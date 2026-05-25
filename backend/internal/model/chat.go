package model

import "time"

// ChatRoom represents a chat room between a customer, a shop, and/or a shipper.
type ChatRoom struct {
	ID                string     `json:"id"`
	RoomType          string     `json:"room_type"` // 'customer_shop', 'shipper_customer', 'shipper_shop'
	CustomerID        *string    `json:"customer_id,omitempty"`
	ShopID            *string    `json:"shop_id,omitempty"`
	ShipperID         *string    `json:"shipper_id,omitempty"`
	AssociatedOrderID *string    `json:"associated_order_id,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
	
	// Display details for convenience
	PartnerName   string `json:"partner_name,omitempty"`
	PartnerAvatar string `json:"partner_avatar,omitempty"`
	LastMessage   string `json:"last_message,omitempty"`
	UnreadCount   int    `json:"unread_count,omitempty"`
}

// ChatMessage represents a single message in a chat room.
type ChatMessage struct {
	ID         string    `json:"id"`
	RoomID     string    `json:"room_id"`
	SenderID   string    `json:"sender_id"`
	SenderRole string    `json:"sender_role"` // 'customer', 'shop_staff', 'shipper', 'ai_assistant'
	MessageType string   `json:"message_type"` // 'text', 'image'
	Content    string    `json:"content"`
	IsRead     bool      `json:"is_read"`
	CreatedAt  time.Time `json:"created_at"`
}

// CreateChatRoomRequest represents a request to create or fetch a chat room.
type CreateChatRoomRequest struct {
	RoomType          string  `json:"room_type" validate:"required"`
	ShopID            *string `json:"shop_id,omitempty"`
	ShipperID         *string `json:"shipper_id,omitempty"`
	AssociatedOrderID *string `json:"associated_order_id,omitempty"`
}

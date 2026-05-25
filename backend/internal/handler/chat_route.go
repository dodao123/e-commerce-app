package handler

import (
	"context"
	"delivery-app/backend/internal/model"
	"encoding/json"
	"fmt"
	"log"
	"strings"

	"github.com/gorilla/websocket"
)

// routeMessage handles sending real-time WebSocket payloads and triggering AI assistant.
func (h *ChatHandler) routeMessage(ctx context.Context, msg *model.ChatMessage) {
	room, err := h.chatService.GetRoomByID(ctx, msg.RoomID)
	if err != nil {
		return
	}

	var recipientID string
	var targetShop *model.Shop

	switch room.RoomType {
	case "customer_shop":
		if room.ShopID == nil {
			return
		}
		shop, err := h.shopService.GetShopByID(ctx, *room.ShopID)
		if err != nil {
			return
		}
		targetShop = shop
		if msg.SenderRole == "buyer" {
			recipientID = shop.SellerID
		} else {
			if room.CustomerID != nil {
				recipientID = *room.CustomerID
			}
		}
	case "shipper_customer":
		if msg.SenderRole == "shipper" && room.CustomerID != nil {
			recipientID = *room.CustomerID
		} else if msg.SenderRole == "buyer" && room.ShipperID != nil {
			recipientID = *room.ShipperID
		}
	case "shipper_shop":
		if room.ShopID == nil {
			return
		}
		shop, err := h.shopService.GetShopByID(ctx, *room.ShopID)
		if err != nil {
			return
		}
		if msg.SenderRole == "shipper" {
			recipientID = shop.SellerID
		} else if msg.SenderRole == "seller" && room.ShipperID != nil {
			recipientID = *room.ShipperID
		}
	}

	// Broadcast to sender (all active connections of sender)
	h.broadcastToUser(msg.SenderID, msg)

	// Broadcast to recipient if online
	isRecipientOnline := h.broadcastToUser(recipientID, msg)

	// Send DB notification & push notification to recipient
	if recipientID != "" && h.notifService != nil {
		senderName := h.getSenderName(ctx, msg, targetShop)
		title := fmt.Sprintf("Tin nhắn mới từ %s", senderName)
		body := msg.Content
		if msg.MessageType == "sticker" || strings.Contains(msg.Content, "sticker") {
			body = fmt.Sprintf("%s đã gửi bạn 1 sticker", senderName)
		} else if msg.MessageType == "image" || strings.Contains(msg.Content, "uploads/") {
			body = fmt.Sprintf("%s đã gửi bạn 1 ảnh", senderName)
		}

		go h.notifService.PushToUser(recipientID, title, body)
	}

	// Trigger AI Assistant RAG Auto-reply if shop is Offline & AI assistant toggle is true
	if room.RoomType == "customer_shop" && msg.SenderRole == "buyer" {
		if isRecipientOnline {
			log.Printf("[AI Assistant] Skipped: Shop (SellerID: %s) is ONLINE", recipientID)
		} else if targetShop == nil {
			log.Printf("[AI Assistant] Skipped: Target shop is nil")
		} else if !targetShop.AIAssistantEnabled {
			log.Printf("[AI Assistant] Skipped: AI Assistant is disabled for shop '%s'", targetShop.ShopName)
		} else {
			go h.triggerAIAssistant(context.Background(), msg, targetShop)
		}
	}
}

func (h *ChatHandler) getSenderName(ctx context.Context, msg *model.ChatMessage, targetShop *model.Shop) string {
	if msg.SenderRole == "ai_assistant" {
		if targetShop != nil {
			return targetShop.ShopName
		}
		return "Trợ lý AI"
	}
	if msg.SenderRole == "seller" && targetShop != nil {
		return targetShop.ShopName
	}
	if h.userRepo != nil {
		user, err := h.userRepo.FindByID(msg.SenderID)
		if err == nil && user != nil && user.FullName != "" {
			return user.FullName
		}
	}
	switch msg.SenderRole {
	case "buyer":
		return "Khách hàng"
	case "shipper":
		return "Tài xế"
	case "seller":
		return "Cửa hàng"
	}
	return "Người dùng"
}

func (h *ChatHandler) broadcastToUser(userID string, msg *model.ChatMessage) bool {
	if userID == "" {
		return false
	}
	h.mu.Lock()
	conns, exists := h.hub[userID]
	h.mu.Unlock()

	if !exists || len(conns) == 0 {
		return false
	}

	payload, _ := json.Marshal(msg)
	for _, conn := range conns {
		_ = conn.WriteMessage(websocket.TextMessage, payload)
	}
	return true
}

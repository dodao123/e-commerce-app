package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

// HandleWebSocket upgrades connection and runs WebSocket listener.
func (h *ChatHandler) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	fmt.Printf("🔴 w's type is %T\n", w)
	claims, err := h.jwtService.ValidateToken(token)
	if err != nil {
		fmt.Printf("🔴 WebSocket token validation failed: %v (token len: %d)\n", err, len(token))
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Printf("🔴 WebSocket upgrade failed: %v\n", err)
		return
	}

	userID := claims.UserID
	role := claims.Role

	h.mu.Lock()
	h.hub[userID] = append(h.hub[userID], conn)
	h.mu.Unlock()

	defer func() {
		conn.Close()
		h.mu.Lock()
		conns := h.hub[userID]
		for i, c := range conns {
			if c == conn {
				h.hub[userID] = append(conns[:i], conns[i+1:]...)
				break
			}
		}
		if len(h.hub[userID]) == 0 {
			delete(h.hub, userID)
		}
		h.mu.Unlock()
	}()

	for {
		_, payload, err := conn.ReadMessage()
		if err != nil {
			break
		}

		var incoming struct {
			RoomID      string `json:"room_id"`
			MessageType string `json:"message_type"`
			Content     string `json:"content"`
		}
		if err := json.Unmarshal(payload, &incoming); err != nil {
			continue
		}

		ctx := context.Background()
		msg, err := h.chatService.SendMessage(ctx, userID, role, incoming.RoomID, incoming.Content, incoming.MessageType)
		if err != nil {
			continue
		}

		h.routeMessage(ctx, msg)
	}
}

package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

// ChatHandler manages all chat HTTP REST endpoints and WebSocket handshakes.
type ChatHandler struct {
	chatService   *service.ChatService
	shopService   *service.ShopService
	searchService *service.SearchService
	jwtService    *service.JWTService
	notifService  *service.NotificationService
	userRepo      *repository.PostgresUserRepository
	upgrader      websocket.Upgrader
	
	// WebSocket Connection Hub
	mu  sync.Mutex
	hub map[string][]*websocket.Conn
}

// NewChatHandler initializes a new ChatHandler.
func NewChatHandler(
	chatService *service.ChatService,
	shopService *service.ShopService,
	searchService *service.SearchService,
	jwtService *service.JWTService,
	notifService *service.NotificationService,
	userRepo *repository.PostgresUserRepository,
) *ChatHandler {
	return &ChatHandler{
		chatService:   chatService,
		shopService:   shopService,
		searchService: searchService,
		jwtService:    jwtService,
		notifService:  notifService,
		userRepo:      userRepo,
		upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool { return true },
		},
		hub: make(map[string][]*websocket.Conn),
	}
}

// HandleGetOrCreateRoom handles POST /api/v1/chat/rooms.
func (h *ChatHandler) HandleGetOrCreateRoom(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		WriteError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	userID, ok := r.Context().Value(middleware.UserIDKey).(string)
	if !ok {
		WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req model.CreateChatRoomRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	room, err := h.chatService.GetOrCreateRoom(r.Context(), userID, &req)
	if err != nil {
		WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}
	WriteJSON(w, http.StatusOK, room)
}

// HandleListRooms handles GET /api/v1/chat/rooms.
func (h *ChatHandler) HandleListRooms(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		WriteError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	userID, ok := r.Context().Value(middleware.UserIDKey).(string)
	role, _ := r.Context().Value(middleware.UserRoleKey).(string)
	if !ok {
		WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	rooms, err := h.chatService.ListRooms(r.Context(), userID, role)
	if err != nil {
		WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}
	WriteJSON(w, http.StatusOK, rooms)
}

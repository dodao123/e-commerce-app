// Package handler provides order HTTP handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"net/http"
)

// OrderHandler handles order HTTP requests.
type OrderHandler struct {
	orderService *service.OrderService
}

// NewOrderHandler creates a new order handler.
func NewOrderHandler(
	svc *service.OrderService,
) *OrderHandler {
	return &OrderHandler{orderService: svc}
}

// HandlePlaceOrder handles POST /api/v1/orders.
func (h *OrderHandler) HandlePlaceOrder(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	var req service.PlaceOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		WriteError(w, http.StatusBadRequest, "invalid body")
		return
	}
	order, err := h.orderService.PlaceOrder(userID, req)
	if err != nil {
		WriteError(w, http.StatusBadRequest, err.Error())
		return
	}
	WriteJSON(w, http.StatusCreated, order)
}

// HandleListOrders handles GET /api/v1/orders.
func (h *OrderHandler) HandleListOrders(
	w http.ResponseWriter, r *http.Request,
) {
	userID := r.Context().Value(
		middleware.UserIDKey).(string)
	orders, err := h.orderService.ListOrders(userID)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to list orders")
		return
	}
	if orders == nil {
		orders = []model.Order{}
	}
	WriteJSON(w, http.StatusOK, orders)
}

// HandleOrderDetail handles GET /api/v1/orders/{id}.
func (h *OrderHandler) HandleOrderDetail(
	w http.ResponseWriter, r *http.Request,
) {
	orderID := r.PathValue("id")
	detail, err := h.orderService.GetOrderDetail(orderID)
	if err != nil {
		WriteError(w, http.StatusNotFound,
			"order not found")
		return
	}
	WriteJSON(w, http.StatusOK, detail)
}

// HandleUpdateStatus handles PUT /api/v1/orders/{id}/status.
func (h *OrderHandler) HandleUpdateStatus(
	w http.ResponseWriter, r *http.Request,
) {
	orderID := r.PathValue("id")
	var req struct {
		Status string `json:"status"`
	}
	if err := ReadJSON(r, &req); err != nil {
		WriteError(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := h.orderService.UpdateOrderStatus(
		orderID, req.Status); err != nil {
		WriteError(w, http.StatusInternalServerError,
			"update failed")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]string{"status": req.Status})
}

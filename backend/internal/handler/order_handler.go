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

// HandleListDriverOrders handles GET /api/v1/driver/orders.
func (h *OrderHandler) HandleListDriverOrders(
	w http.ResponseWriter, r *http.Request,
) {
	driverID := r.Context().Value(
		middleware.UserIDKey).(string)
	orders, err := h.orderService.ListDriverOrders(driverID)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed to list driver orders")
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

// HandleAcceptDelivery handles POST /api/v1/orders/{id}/accept-delivery
func (h *OrderHandler) HandleAcceptDelivery(
	w http.ResponseWriter, r *http.Request,
) {
	orderID := r.PathValue("id")
	// The user info should ideally come from Context/Auth, but for MVP we might need Name/Phone from token or request body.
	// We'll read from Context. Wait, UserID is in context, but Name/Phone might not be.
	// We'll require Name/Phone in the request body for simplicity, or we can fetch the user.
	// Let's require them in the body.
	var req struct {
		DriverName  string `json:"driver_name"`
		DriverPhone string `json:"driver_phone"`
	}
	if err := ReadJSON(r, &req); err != nil {
		WriteError(w, http.StatusBadRequest, "invalid body")
		return
	}
	driverID := r.Context().Value(middleware.UserIDKey).(string)

	if err := h.orderService.AcceptOrderDelivery(
		orderID, driverID, req.DriverName, req.DriverPhone); err != nil {
		WriteError(w, http.StatusConflict, err.Error())
		return
	}

	WriteJSON(w, http.StatusOK, map[string]string{"message": "Order accepted successfully"})
}

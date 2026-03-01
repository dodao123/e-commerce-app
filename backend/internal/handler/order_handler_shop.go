// Package handler provides shop order HTTP handlers.
package handler

import (
	"net/http"
)

// HandleShopOrders handles GET /api/v1/shop/orders.
func (h *OrderHandler) HandleShopOrders(
	w http.ResponseWriter, r *http.Request,
) {
	shopID := r.URL.Query().Get("shop_id")
	if shopID == "" {
		WriteError(w, http.StatusBadRequest,
			"shop_id required")
		return
	}
	orders, err := h.orderService.ListShopOrders(shopID)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed")
		return
	}
	WriteJSON(w, http.StatusOK, orders)
}

// HandleShopOrderCount handles GET /api/v1/shop/orders/count.
func (h *OrderHandler) HandleShopOrderCount(
	w http.ResponseWriter, r *http.Request,
) {
	shopID := r.URL.Query().Get("shop_id")
	if shopID == "" {
		WriteError(w, http.StatusBadRequest,
			"shop_id required")
		return
	}
	count, err := h.orderService.CountShopPending(shopID)
	if err != nil {
		WriteError(w, http.StatusInternalServerError,
			"failed")
		return
	}
	WriteJSON(w, http.StatusOK,
		map[string]int{"count": count})
}

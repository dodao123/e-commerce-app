// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/model"
	"net/http"
)

// HandleListPublicProducts handles GET /api/v1/products/public.
// Returns active products from all shops with shop info.
// No authentication required.
func (handler *ProductHandler) HandleListPublicProducts(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	limit := queryInt(request, "limit", 10)
	offset := queryInt(request, "offset", 0)

	products, err := handler.productService.ListPublicProducts(
		request.Context(), limit, offset)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError,
			err.Error())
		return
	}

	if products == nil {
		products = make([]*model.PublicProduct, 0)
	}

	WriteJSON(writer, http.StatusOK, products)
}

// HandleListShopProducts handles GET /api/v1/shops/{shopId}/products.
// Returns active products from a specific shop (public).
func (handler *ProductHandler) HandleListShopProducts(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	shopID := request.PathValue("shopId")
	if shopID == "" {
		WriteError(writer, http.StatusBadRequest, "missing shop ID")
		return
	}

	excludeID := request.URL.Query().Get("exclude")
	limit := queryInt(request, "limit", 10)

	products, err := handler.productService.ListShopProducts(
		request.Context(), shopID, excludeID, limit)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError,
			err.Error())
		return
	}

	if products == nil {
		products = make([]*model.PublicProduct, 0)
	}

	WriteJSON(writer, http.StatusOK, products)
}

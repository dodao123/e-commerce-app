// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"log"
	"net/http"
	"strconv"
)

// ProductHandler handles HTTP requests for product operations.
type ProductHandler struct {
	productService *service.ProductService
	imageService   *service.ImageService
}

// NewProductHandler creates a new product handler instance.
func NewProductHandler(
	productService *service.ProductService,
	imageService *service.ImageService,
) *ProductHandler {
	return &ProductHandler{
		productService: productService,
		imageService:   imageService,
	}
}

// HandleCreateProduct handles POST /api/v1/products.
func (handler *ProductHandler) HandleCreateProduct(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	sellerID, ok := request.Context().Value(
		middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	log.Printf("📦 Creating product for seller %s", sellerID)

	var createRequest model.CreateProductRequest
	if err := json.NewDecoder(request.Body).Decode(
		&createRequest); err != nil {
		log.Printf("❌ Invalid body: %v", err)
		WriteError(writer, http.StatusBadRequest,
			"invalid request body")
		return
	}

	log.Printf("📦 Product: %s, price: %.0f",
		createRequest.Name, createRequest.Price)

	product, err := handler.productService.CreateProduct(
		request.Context(), sellerID, &createRequest)
	if err != nil {
		log.Printf("❌ Create failed: %v", err)
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	log.Printf("✅ Product created: %s", product.ID)

	WriteJSON(writer, http.StatusCreated, product)
}

// HandleListProducts handles GET /api/v1/products.
func (handler *ProductHandler) HandleListProducts(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	sellerID, ok := request.Context().Value(
		middleware.UserIDKey).(string)
	if !ok {
		WriteError(writer, http.StatusUnauthorized, "unauthorized")
		return
	}

	status := request.URL.Query().Get("status")
	limit := queryInt(request, "limit", 20)
	offset := queryInt(request, "offset", 0)

	products, err := handler.productService.ListProducts(
		request.Context(), sellerID, status, limit, offset)
	if err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, products)
}

// queryInt parses an integer query parameter with a default.
func queryInt(r *http.Request, key string, def int) int {
	val := r.URL.Query().Get(key)
	if val == "" {
		return def
	}
	n, err := strconv.Atoi(val)
	if err != nil {
		return def
	}
	return n
}

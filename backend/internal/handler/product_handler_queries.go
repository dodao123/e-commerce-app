// Package handler provides HTTP request handlers.
package handler

import (
	"delivery-app/backend/internal/middleware"
	"fmt"
	"log"
	"net/http"
)

// HandleGetProduct handles GET /api/v1/products/{id}.
func (handler *ProductHandler) HandleGetProduct(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	productID := request.PathValue("id")
	if productID == "" {
		WriteError(writer, http.StatusBadRequest,
			"product ID required")
		return
	}

	product, err := handler.productService.GetProduct(
		request.Context(), productID)
	if err != nil {
		WriteError(writer, http.StatusNotFound, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, product)
}

// HandleDeleteProduct handles DELETE /api/v1/products/{id}.
func (handler *ProductHandler) HandleDeleteProduct(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodDelete {
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

	productID := request.PathValue("id")
	if productID == "" {
		WriteError(writer, http.StatusBadRequest,
			"product ID required")
		return
	}

	if err := handler.productService.DeleteProduct(
		request.Context(), sellerID, productID); err != nil {
		WriteError(writer, http.StatusBadRequest, err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK,
		map[string]string{"message": fmt.Sprintf(
			"product %s deleted", productID)})
}

// HandleUploadImages handles POST /api/v1/products/{id}/images.
func (handler *ProductHandler) HandleUploadImages(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	productID := request.PathValue("id")
	if productID == "" {
		WriteError(writer, http.StatusBadRequest,
			"product ID required")
		return
	}

	if err := request.ParseMultipartForm(
		10 << 20 * 10); err != nil {
		WriteError(writer, http.StatusBadRequest,
			"failed to parse form")
		return
	}

	product, err := handler.productService.GetProduct(
		request.Context(), productID)
	if err != nil {
		WriteError(writer, http.StatusNotFound, err.Error())
		return
	}

	folder, err := handler.imageService.EnsureProductFolder(
		product.ShopID, product.ID)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError,
			"failed to create folder")
		return
	}

	files := request.MultipartForm.File["images"]
	var urls []string
	for _, fileHeader := range files {
		path, saveErr := handler.imageService.SaveAndProcess(
			folder, fileHeader)
		if saveErr != nil {
			log.Printf("❌ Image save failed: %v", saveErr)
			continue
		}
		urls = append(urls, path)
	}

	// Save image URLs to product record in database
	if len(urls) > 0 {
		product.Images = append(product.Images, urls...)
		if err := handler.productService.UpdateProductImages(
			request.Context(), product); err != nil {
			log.Printf("❌ Update images DB: %v", err)
		}
	}

	log.Printf("📸 Uploaded %d images for product %s",
		len(urls), productID)
	WriteJSON(writer, http.StatusOK,
		map[string]any{"uploaded": urls})
}


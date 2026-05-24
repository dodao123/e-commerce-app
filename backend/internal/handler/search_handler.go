// Package handler provides HTTP handlers for hybrid search.
package handler

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"net/http"
)

// SearchHandler handles hybrid search API requests.
type SearchHandler struct {
	searchService *service.SearchService
	syncService   *service.EmbeddingSyncService
}

// NewSearchHandler creates a new search handler.
func NewSearchHandler(
	searchSvc *service.SearchService,
	syncSvc *service.EmbeddingSyncService,
) *SearchHandler {
	return &SearchHandler{
		searchService: searchSvc,
		syncService:   syncSvc,
	}
}

// HandleHybridSearch handles GET /api/v1/search?q=...
func (h *SearchHandler) HandleHybridSearch(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodGet {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	query := request.URL.Query().Get("q")
	if query == "" {
		WriteError(writer, http.StatusBadRequest,
			"query parameter 'q' is required")
		return
	}

	limit := queryInt(request, "limit", 20)

	products, exactCount, err := h.searchService.HybridSearch(
		request.Context(), query, limit)
	if err != nil {
		WriteError(writer, http.StatusInternalServerError,
			err.Error())
		return
	}

	if products == nil {
		products = make([]*model.PublicProduct, 0)
	}

	WriteJSON(writer, http.StatusOK, map[string]interface{}{
		"products":    products,
		"count":       len(products),
		"exact_count": exactCount,
	})
}

// HandleSyncEmbeddings handles POST /api/v1/embeddings/sync
func (h *SearchHandler) HandleSyncEmbeddings(
	writer http.ResponseWriter,
	request *http.Request,
) {
	if request.Method != http.MethodPost {
		WriteError(writer, http.StatusMethodNotAllowed,
			"method not allowed")
		return
	}

	count, err := h.syncService.SyncAllProducts(request.Context())
	if err != nil {
		WriteError(writer, http.StatusInternalServerError,
			err.Error())
		return
	}

	WriteJSON(writer, http.StatusOK, map[string]interface{}{
		"synced": count,
		"status": "completed",
	})
}

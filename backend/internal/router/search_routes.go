// Package router provides route registration for search endpoints.
package router

import (
	"delivery-app/backend/internal/handler"
	"net/http"
)

// registerSearchRoutes registers semantic search API routes.
func registerSearchRoutes(
	mux *http.ServeMux,
	searchHandler *handler.SearchHandler,
) {
	if searchHandler == nil {
		return
	}

	// Public hybrid search (keyword + semantic, no auth required)
	mux.HandleFunc("/api/v1/search",
		searchHandler.HandleHybridSearch)

	// Admin: trigger embedding sync (no auth for now)
	mux.HandleFunc("/api/v1/embeddings/sync",
		searchHandler.HandleSyncEmbeddings)
}

// Package service provides hybrid search orchestration.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
	"log"
)

// SearchService orchestrates hybrid keyword + semantic search.
type SearchService struct {
	embeddingService *EmbeddingService
	embeddingRepo    repository.EmbeddingRepository
	productRepo      repository.ProductRepository
}

// NewSearchService creates a new hybrid search service.
func NewSearchService(
	embSvc *EmbeddingService,
	embRepo repository.EmbeddingRepository,
	prodRepo repository.ProductRepository,
) *SearchService {
	return &SearchService{
		embeddingService: embSvc,
		embeddingRepo:    embRepo,
		productRepo:      prodRepo,
	}
}

// HybridSearch merges keyword matches (top) with semantic results (below).
func (s *SearchService) HybridSearch(
	ctx context.Context, query string, limit int,
) ([]*model.PublicProduct, int, error) {
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	// Step 1: Keyword matches go first
	keywordResults, _ := s.productRepo.ListAllPublicProducts(
		ctx, "", query, limit, 0)
	exactCount := len(keywordResults)

	// Step 2: Semantic vector results fill remaining slots
	remaining := limit - exactCount
	if remaining < 5 {
		remaining = 5
	}
	semanticResults, err := s.semanticSearch(ctx, query, remaining)
	if err != nil {
		log.Printf("[Search] semantic fallback error: %v", err)
	}

	// Step 3: Merge — keyword first, then semantic (deduplicated)
	merged := s.mergeResults(keywordResults, semanticResults)
	_ = s.embeddingRepo.LogSearch(ctx, query, len(merged))
	return merged, exactCount, nil
}

// mergeResults combines keyword and semantic lists, removing duplicates.
func (s *SearchService) mergeResults(
	keyword, semantic []*model.PublicProduct,
) []*model.PublicProduct {
	seen := make(map[string]bool, len(keyword))
	merged := make([]*model.PublicProduct, 0, len(keyword)+len(semantic))

	for _, p := range keyword {
		seen[p.ID] = true
		merged = append(merged, p)
	}
	for _, p := range semantic {
		if !seen[p.ID] {
			seen[p.ID] = true
			merged = append(merged, p)
		}
	}
	return merged
}

// semanticSearch converts query to vector and finds similar products.
func (s *SearchService) semanticSearch(
	ctx context.Context, query string, limit int,
) ([]*model.PublicProduct, error) {
	queryVector, err := s.embeddingService.Embed(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("embed query failed: %w", err)
	}

	matches, err := s.embeddingRepo.SearchSimilar(ctx, queryVector, limit)
	if err != nil {
		return nil, fmt.Errorf("similarity search failed: %w", err)
	}

	var products []*model.PublicProduct
	for _, m := range matches {
		if m.Similarity < 0.3 {
			continue
		}
		p, err := s.productRepo.GetPublicProductByID(ctx, m.ProductID)
		if err != nil {
			continue
		}
		products = append(products, p)
	}
	return products, nil
}

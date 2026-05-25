// Package service provides the batch embedding sync worker.
package service

import (
	"context"
	"delivery-app/backend/internal/repository"
	"fmt"
	"log"
	"strings"
)

// EmbeddingSyncService handles batch embedding of products.
type EmbeddingSyncService struct {
	embeddingService *EmbeddingService
	embeddingRepo    repository.EmbeddingRepository
	productRepo      repository.ProductRepository
}

// NewEmbeddingSyncService creates a new sync service.
func NewEmbeddingSyncService(
	embSvc *EmbeddingService,
	embRepo repository.EmbeddingRepository,
	prodRepo repository.ProductRepository,
) *EmbeddingSyncService {
	return &EmbeddingSyncService{
		embeddingService: embSvc,
		embeddingRepo:    embRepo,
		productRepo:      prodRepo,
	}
}

// SyncAllProducts embeds all active products in the database.
func (s *EmbeddingSyncService) SyncAllProducts(
	ctx context.Context,
) (int, error) {
	products, err := s.productRepo.ListAllPublicProducts(
		ctx, "", "", 500, 0)
	if err != nil {
		return 0, fmt.Errorf("fetch products failed: %w", err)
	}

	synced := 0
	for _, p := range products {
		// Skip if already embedded
		if exists, _ := s.embeddingRepo.HasEmbedding(ctx, p.ID); exists {
			synced++
			continue
		}

		text := buildProductText(
			p.Name, p.Description,
			string(p.Category), p.ShopName)

		vector, err := s.embeddingService.Embed(ctx, text)
		if err != nil {
			log.Printf("[EmbSync] skip %s: %v", p.ID, err)
			continue
		}

		emb := &repository.ProductEmbedding{
			ProductID:    p.ID,
			Embedding:    vector,
			TextContent:  text,
			ModelVersion: "gemini-embedding-001",
		}
		if err := s.embeddingRepo.Upsert(ctx, emb); err != nil {
			log.Printf("[EmbSync] upsert %s: %v", p.ID, err)
			continue
		}
		synced++
		log.Printf("[EmbSync] ✅ %d/%d %s", synced, len(products), p.Name)
	}
	return synced, nil
}

// buildProductText creates searchable text from product fields.
func buildProductText(
	name, description, category, shopName string,
) string {
	parts := []string{name}
	if description != "" {
		parts = append(parts, description)
	}
	if category != "" {
		parts = append(parts, "Category: "+category)
	}
	if shopName != "" {
		parts = append(parts, "Shop: "+shopName)
	}
	return strings.Join(parts, ". ")
}

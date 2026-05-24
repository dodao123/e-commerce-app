// Package repository provides the embedding repository interface.
package repository

import "context"

// ProductEmbedding represents a stored product vector.
type ProductEmbedding struct {
	// ID is the embedding row UUID.
	ID string

	// ProductID references the source product.
	ProductID string

	// Embedding is the float64 vector.
	Embedding []float64

	// TextContent is the source text used for embedding.
	TextContent string

	// ModelVersion identifies the model used.
	ModelVersion string
}

// SemanticSearchResult holds a product match with similarity score.
type SemanticSearchResult struct {
	// ProductID is the matched product UUID.
	ProductID string

	// Similarity is the cosine similarity score (0.0–1.0).
	Similarity float64
}

// EmbeddingRepository defines storage operations for vectors.
type EmbeddingRepository interface {
	// Upsert inserts or updates a product embedding.
	Upsert(ctx context.Context, emb *ProductEmbedding) error

	// SearchSimilar finds the top-K most similar products.
	SearchSimilar(
		ctx context.Context,
		queryVector []float64,
		limit int,
	) ([]SemanticSearchResult, error)

	// LogSearch records a search query for analytics.
	LogSearch(ctx context.Context, query string, count int) error

	// CountEmbeddings returns total stored embeddings.
	CountEmbeddings(ctx context.Context) (int, error)
}

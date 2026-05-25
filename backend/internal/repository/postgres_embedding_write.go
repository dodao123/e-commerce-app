package repository

import (
	"context"
	"database/sql"
	"fmt"
)

// PostgresEmbeddingRepository implements EmbeddingRepository using pgvector.
type PostgresEmbeddingRepository struct {
	database *sql.DB
}

// NewPostgresEmbeddingRepository creates a new pgvector-backed repository.
func NewPostgresEmbeddingRepository(db *sql.DB) *PostgresEmbeddingRepository {
	return &PostgresEmbeddingRepository{database: db}
}

// Upsert inserts or replaces a product embedding row.
func (r *PostgresEmbeddingRepository) Upsert(
	ctx context.Context, emb *ProductEmbedding,
) error {
	vectorStr := formatVector(emb.Embedding)
	query := `INSERT INTO product_embeddings
		(product_id, embedding, text_content, model_version)
		VALUES ($1, $2::vector, $3, $4)
		ON CONFLICT (product_id)
		DO UPDATE SET embedding = $2::vector,
			text_content = $3, model_version = $4,
			created_at = NOW()`
	_, err := r.database.ExecContext(ctx, query,
		emb.ProductID, vectorStr, emb.TextContent, emb.ModelVersion)
	if err != nil {
		return fmt.Errorf("upsert embedding failed: %w", err)
	}
	return nil
}

// LogSearch records a search query for analytics.
func (r *PostgresEmbeddingRepository) LogSearch(
	ctx context.Context, query string, count int,
) error {
	_, err := r.database.ExecContext(ctx,
		`INSERT INTO search_logs (query, result_count) VALUES ($1, $2)`,
		query, count)
	return err
}

// Package repository provides PostgreSQL embedding storage with pgvector.
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
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

// SearchSimilar finds top-K products by cosine similarity.
func (r *PostgresEmbeddingRepository) SearchSimilar(
	ctx context.Context, queryVector []float64, limit int,
) ([]SemanticSearchResult, error) {
	vectorStr := formatVector(queryVector)
	query := `SELECT product_id,
		1 - (embedding <=> $1::vector) AS similarity
		FROM product_embeddings
		ORDER BY embedding <=> $1::vector
		LIMIT $2`
	rows, err := r.database.QueryContext(ctx, query, vectorStr, limit)
	if err != nil {
		return nil, fmt.Errorf("similarity search failed: %w", err)
	}
	defer rows.Close()

	var results []SemanticSearchResult
	for rows.Next() {
		var sr SemanticSearchResult
		if err := rows.Scan(&sr.ProductID, &sr.Similarity); err != nil {
			return nil, fmt.Errorf("scan result failed: %w", err)
		}
		results = append(results, sr)
	}
	return results, rows.Err()
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

// CountEmbeddings returns total stored embeddings.
func (r *PostgresEmbeddingRepository) CountEmbeddings(
	ctx context.Context,
) (int, error) {
	var count int
	err := r.database.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM product_embeddings`).Scan(&count)
	return count, err
}

// formatVector converts a float64 slice to pgvector string format.
func formatVector(v []float64) string {
	parts := make([]string, len(v))
	for i, val := range v {
		parts[i] = fmt.Sprintf("%f", val)
	}
	return "[" + strings.Join(parts, ",") + "]"
}

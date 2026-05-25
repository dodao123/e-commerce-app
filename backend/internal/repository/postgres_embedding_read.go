package repository

import (
	"context"
	"fmt"
	"strings"
)

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

// CountEmbeddings returns total stored embeddings.
func (r *PostgresEmbeddingRepository) CountEmbeddings(
	ctx context.Context,
) (int, error) {
	var count int
	err := r.database.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM product_embeddings`).Scan(&count)
	return count, err
}

// HasEmbedding checks if a product already has a vector embedding.
func (r *PostgresEmbeddingRepository) HasEmbedding(
	ctx context.Context, productID string,
) (bool, error) {
	var exists bool
	query := `SELECT EXISTS(SELECT 1 FROM product_embeddings WHERE product_id = $1)`
	err := r.database.QueryRowContext(ctx, query, productID).Scan(&exists)
	return exists, err
}

// formatVector converts a float64 slice to pgvector string format.
func formatVector(v []float64) string {
	parts := make([]string, len(v))
	for i, val := range v {
		parts[i] = fmt.Sprintf("%f", val)
	}
	return "[" + strings.Join(parts, ",") + "]"
}

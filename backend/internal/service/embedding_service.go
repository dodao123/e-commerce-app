// Package service provides the Gemini embedding API client.
package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// EmbeddingService wraps the Gemini embedding API.
type EmbeddingService struct {
	apiKey   string
	model    string
	endpoint string
}

// geminiEmbedRequest is the JSON request body.
type geminiEmbedRequest struct {
	Model   string              `json:"model"`
	Content geminiEmbedContent  `json:"content"`
}

// geminiEmbedContent wraps parts for embedding.
type geminiEmbedContent struct {
	Parts []geminiEmbedPart `json:"parts"`
}

// geminiEmbedPart holds a single text chunk.
type geminiEmbedPart struct {
	Text string `json:"text"`
}

// geminiEmbedResponse is the parsed API response.
type geminiEmbedResponse struct {
	Embedding *geminiEmbedData `json:"embedding"`
}

// geminiEmbedData holds the resulting float vector.
type geminiEmbedData struct {
	Values []float64 `json:"values"`
}

// NewEmbeddingService creates a new Gemini embedding client.
func NewEmbeddingService(apiKey string) *EmbeddingService {
	model := "gemini-embedding-001"
	return &EmbeddingService{
		apiKey: apiKey,
		model:  model,
		endpoint: fmt.Sprintf(
			"https://generativelanguage.googleapis.com/v1beta/models/%s:embedContent?key=%s",
			model, apiKey,
		),
	}
}

// Embed generates a vector embedding for the given text.
func (s *EmbeddingService) Embed(
	ctx context.Context, text string,
) ([]float64, error) {
	body := geminiEmbedRequest{
		Model: "models/" + s.model,
		Content: geminiEmbedContent{
			Parts: []geminiEmbedPart{{Text: text}},
		},
	}
	jsonBytes, _ := json.Marshal(body)

	req, err := http.NewRequestWithContext(
		ctx, http.MethodPost, s.endpoint,
		strings.NewReader(string(jsonBytes)))
	if err != nil {
		return nil, fmt.Errorf("create request failed: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("embedding request failed: %w", err)
	}
	defer resp.Body.Close()

	respBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error %d: %s",
			resp.StatusCode, string(respBytes))
	}

	var result geminiEmbedResponse
	if err := json.Unmarshal(respBytes, &result); err != nil {
		return nil, fmt.Errorf("JSON parse failed: %w", err)
	}
	if result.Embedding == nil {
		return nil, fmt.Errorf("no embedding returned")
	}
	return result.Embedding.Values, nil
}

// Package service provides business logic for the application.
package service

import (
	"bytes"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
)

// removeBackground calls the Python bg_remover microservice.
// The bg_remover must be running independently on bgRemoverURL.
func (service *ImageService) removeBackground(
	imageData []byte,
	filename string,
) ([]byte, error) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	part, err := writer.CreateFormFile("image", filename)
	if err != nil {
		return nil, fmt.Errorf("failed to create form: %w", err)
	}

	if _, err = part.Write(imageData); err != nil {
		return nil, fmt.Errorf("failed to write form: %w", err)
	}
	writer.Close()

	url := service.bgRemoverURL + "/remove-bg"
	request, err := http.NewRequest("POST", url, body)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	request.Header.Set("Content-Type",
		writer.FormDataContentType())

	response, err := service.httpClient.Do(request)
	if err != nil {
		return nil, fmt.Errorf("bg service unreachable: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("bg service returned %d",
			response.StatusCode)
	}

	return io.ReadAll(response.Body)
}

// saveBytes writes raw bytes to disk.
func (service *ImageService) saveBytes(
	outputPath string,
	data []byte,
) (string, error) {
	if err := os.WriteFile(outputPath, data, 0644); err != nil {
		return "", fmt.Errorf("failed to save file: %w", err)
	}
	return outputPath, nil
}

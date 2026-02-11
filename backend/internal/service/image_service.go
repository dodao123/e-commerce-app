// Package service provides business logic for the application.
package service

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"
)

// ImageService handles image storage and background removal.
type ImageService struct {
	// uploadRoot is the base directory for uploads.
	uploadRoot string

	// bgRemoverURL is the Python service endpoint.
	bgRemoverURL string

	// httpClient is used to call the Python service.
	httpClient *http.Client
}

// NewImageService creates a new ImageService instance.
func NewImageService(
	uploadRoot string,
	bgRemoverURL string,
) *ImageService {
	return &ImageService{
		uploadRoot:   uploadRoot,
		bgRemoverURL: bgRemoverURL,
		httpClient: &http.Client{
			Timeout: 120 * time.Second,
		},
	}
}

// EnsureProductFolder creates the upload folder for a product.
// Path: uploads/shops/{shopID}/{productID}/
func (service *ImageService) EnsureProductFolder(
	shopID string,
	productID string,
) (string, error) {
	folderPath := filepath.Join(
		service.uploadRoot, "shops", shopID, productID)

	if err := os.MkdirAll(folderPath, 0755); err != nil {
		return "", fmt.Errorf("failed to create folder: %w", err)
	}
	return folderPath, nil
}

// SaveAndProcess saves an uploaded image, calls bg removal,
// and returns the relative file path (e.g. uploads/shops/.../file.png).
func (service *ImageService) SaveAndProcess(
	folder string,
	fileHeader *multipart.FileHeader,
) (string, error) {
	// Open uploaded file
	source, err := fileHeader.Open()
	if err != nil {
		return "", fmt.Errorf("failed to open upload: %w", err)
	}
	defer source.Close()

	// Read file bytes
	fileBytes, err := io.ReadAll(source)
	if err != nil {
		return "", fmt.Errorf("failed to read upload: %w", err)
	}

	// Generate unique filename
	fileName := uuid.New().String() + ".png"
	outputPath := filepath.Join(folder, fileName)

	// Call background removal service (mandatory)
	processed, bgErr := service.removeBackground(
		fileBytes, fileHeader.Filename)
	if bgErr != nil {
		return "", fmt.Errorf("bg removal failed: %w", bgErr)
	}

	_, saveErr := service.saveBytes(outputPath, processed)
	if saveErr != nil {
		return "", saveErr
	}
	return service.toRelativePath(outputPath), nil
}

// toRelativePath converts absolute path to relative from CWD.
func (service *ImageService) toRelativePath(
	absPath string,
) string {
	rel, err := filepath.Rel(".", absPath)
	if err != nil {
		return absPath
	}
	return filepath.ToSlash(rel)
}

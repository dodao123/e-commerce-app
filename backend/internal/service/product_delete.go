// Package service provides business logic implementations.
package service

import (
	"fmt"
	"os"
	"path/filepath"
)

// DeleteProductImages removes specific image files from disk
// and returns the remaining images list.
func (service *ProductService) DeleteProductImages(
	shopID string,
	productID string,
	imagePathsToDelete []string,
	currentImages []string,
) ([]string, error) {
	for _, imagePath := range imagePathsToDelete {
		absPath := filepath.Join(".", imagePath)
		if err := os.Remove(absPath); err != nil && !os.IsNotExist(err) {
			fmt.Printf("⚠️ Failed to delete image %s: %v\n",
				imagePath, err)
		}
	}

	remaining := filterOutImages(currentImages, imagePathsToDelete)
	return remaining, nil
}

// DeleteProductFolder removes the entire image folder for a product.
func (service *ProductService) DeleteProductFolder(
	shopID string,
	productID string,
) error {
	folderPath := filepath.Join(
		service.imageService.uploadRoot,
		"shops", shopID, productID)

	if err := os.RemoveAll(folderPath); err != nil {
		return fmt.Errorf("failed to delete folder: %w", err)
	}
	return nil
}

// filterOutImages returns images not in the toRemove list.
func filterOutImages(
	images []string,
	toRemove []string,
) []string {
	removeSet := make(map[string]bool, len(toRemove))
	for _, path := range toRemove {
		removeSet[path] = true
	}

	var remaining []string
	for _, img := range images {
		if !removeSet[img] {
			remaining = append(remaining, img)
		}
	}
	if remaining == nil {
		remaining = []string{}
	}
	return remaining
}

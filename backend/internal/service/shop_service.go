// Package service provides business logic implementations.
package service

import (
	"context"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"fmt"
	"os"
	"path/filepath"
)

// ShopService handles business logic for shop operations.
type ShopService struct {
	shopRepository repository.ShopRepository
	userRepository repository.UserRepository
}

// NewShopService creates a new shop service instance.
func NewShopService(
	shopRepository repository.ShopRepository,
	userRepository repository.UserRepository,
) *ShopService {
	return &ShopService{
		shopRepository: shopRepository,
		userRepository: userRepository,
	}
}

// CreateShop creates a new shop for a seller.
// Validates that the user is a seller and doesn't already have a shop.
func (service *ShopService) CreateShop(
	ctx context.Context,
	sellerID string,
	request *model.CreateShopRequest,
) (*model.Shop, error) {
	// Verify user exists and is a seller
	user, err := service.userRepository.FindByID(sellerID)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	if user.Role != model.RoleSeller {
		return nil, fmt.Errorf("user is not a seller")
	}

	// Check if seller already has a shop
	existingShop, err := service.shopRepository.GetShopBySellerID(
		ctx, sellerID,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to check existing shop: %w", err)
	}

	if existingShop != nil {
		return nil, fmt.Errorf("seller already has a shop")
	}

	// Create the shop
	shop := &model.Shop{
		SellerID:         sellerID,
		ShopName:         request.ShopName,
		Category:         model.ShopCategory(request.Category),
		Province:         request.Province,
		District:         request.District,
		Ward:             request.Ward,
		DetailAddress:    request.DetailAddress,
		Latitude:         request.Latitude,
		Longitude:        request.Longitude,
		Email:            request.Email,
		Phone:            request.Phone,
		Nationality:      request.Nationality,
		NationalIDNumber: request.NationalIDNumber,
		FullName:         request.FullName,
		IsVerified:       false,
		IsActive:         true,
	}

	if err := service.shopRepository.CreateShop(ctx, shop); err != nil {
		return nil, fmt.Errorf("failed to create shop: %w", err)
	}

	return shop, nil
}

// GetShopByID retrieves a shop by its ID.
func (service *ShopService) GetShopByID(
	ctx context.Context,
	shopID string,
) (*model.Shop, error) {
	return service.shopRepository.GetShopByID(ctx, shopID)
}

// GetPublicShopByID retrieves a public view of a shop by its ID.
func (service *ShopService) GetPublicShopByID(
	ctx context.Context,
	shopID string,
) (*model.PublicShop, error) {
	shop, err := service.shopRepository.GetShopByID(ctx, shopID)
	if err != nil {
		return nil, err
	}

	avatar := ""
	user, err := service.userRepository.FindByID(shop.SellerID)
	if err == nil && user != nil && len(user.AvatarURL) >= 4 && user.AvatarURL[:4] == "http" {
		avatar = user.AvatarURL
	} else {
		logoPath := filepath.Join("uploads", "logos", fmt.Sprintf("shop_%s.png", shop.ID))
		if _, err := os.Stat(logoPath); err == nil {
			avatar = fmt.Sprintf("/uploads/logos/shop_%s.png", shop.ID)
		} else if err == nil && user != nil {
			avatar = user.AvatarURL
		}
	}

	return &model.PublicShop{
		Shop:       *shop,
		ShopAvatar: avatar,
	}, nil
}

// ListPublicShops retrieves active shops with pagination.
func (service *ShopService) ListPublicShops(
	ctx context.Context,
	limit int,
	offset int,
) ([]*model.PublicShop, error) {
	shops, err := service.shopRepository.ListShops(ctx, limit, offset)
	if err != nil {
		return nil, err
	}

	publicShops := make([]*model.PublicShop, 0, len(shops))
	for _, shop := range shops {
		avatar := ""
		user, err := service.userRepository.FindByID(shop.SellerID)
		if err == nil && user != nil && len(user.AvatarURL) >= 4 && user.AvatarURL[:4] == "http" {
			avatar = user.AvatarURL
		} else {
			logoPath := filepath.Join("uploads", "logos", fmt.Sprintf("shop_%s.png", shop.ID))
			if _, err := os.Stat(logoPath); err == nil {
				avatar = fmt.Sprintf("/uploads/logos/shop_%s.png", shop.ID)
			} else if err == nil && user != nil {
				avatar = user.AvatarURL
			}
		}
		publicShops = append(publicShops, &model.PublicShop{
			Shop:       *shop,
			ShopAvatar: avatar,
		})
	}
	return publicShops, nil
}

// GetShopBySellerID retrieves a shop by seller user ID.
func (service *ShopService) GetShopBySellerID(
	ctx context.Context,
	sellerID string,
) (*model.Shop, error) {
	return service.shopRepository.GetShopBySellerID(ctx, sellerID)
}

// UpdateShop updates shop information.
// Only the shop owner can update their shop.
func (service *ShopService) UpdateShop(
	ctx context.Context,
	shopID string,
	sellerID string,
	request *model.UpdateShopRequest,
) (*model.Shop, error) {
	// Get existing shop
	shop, err := service.shopRepository.GetShopByID(ctx, shopID)
	if err != nil {
		return nil, fmt.Errorf("shop not found: %w", err)
	}

	// Verify ownership
	if shop.SellerID != sellerID {
		return nil, fmt.Errorf("unauthorized: not shop owner")
	}

	// Update fields if provided
	if request.ShopName != nil {
		shop.ShopName = *request.ShopName
	}
	if request.Category != nil {
		shop.Category = model.ShopCategory(*request.Category)
	}
	if request.Province != nil {
		shop.Province = *request.Province
	}
	if request.District != nil {
		shop.District = *request.District
	}
	if request.Ward != nil {
		shop.Ward = *request.Ward
	}
	if request.DetailAddress != nil {
		shop.DetailAddress = *request.DetailAddress
	}
	if request.Email != nil {
		shop.Email = *request.Email
	}
	if request.Phone != nil {
		shop.Phone = *request.Phone
	}
	if request.Latitude != nil {
		shop.Latitude = *request.Latitude
	}
	if request.Longitude != nil {
		shop.Longitude = *request.Longitude
	}
	if request.Nationality != nil {
		shop.Nationality = *request.Nationality
	}
	if request.NationalIDNumber != nil {
		shop.NationalIDNumber = *request.NationalIDNumber
	}
	if request.FullName != nil {
		shop.FullName = *request.FullName
	}
	if request.AIAssistantEnabled != nil {
		shop.AIAssistantEnabled = *request.AIAssistantEnabled
	}

	if err := service.shopRepository.UpdateShop(ctx, shop); err != nil {
		return nil, fmt.Errorf("failed to update shop: %w", err)
	}

	return shop, nil
}

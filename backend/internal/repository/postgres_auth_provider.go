// Package repository provides database access for domain entities.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
)

// PostgresAuthProviderRepository implements AuthProviderRepository.
type PostgresAuthProviderRepository struct {
	database *sql.DB
}

// NewPostgresAuthProviderRepository creates a new instance.
func NewPostgresAuthProviderRepository(
	database *sql.DB,
) *PostgresAuthProviderRepository {
	return &PostgresAuthProviderRepository{database: database}
}

// FindByProvider finds a provider link by provider and provider ID.
func (repo *PostgresAuthProviderRepository) FindByProvider(
	provider model.AuthProvider,
	providerID string,
) (*model.UserAuthProvider, error) {
	query := `SELECT id, user_id, provider, provider_id, created_at
		FROM user_auth_providers
		WHERE provider = $1 AND provider_id = $2`

	authProvider := &model.UserAuthProvider{}
	err := repo.database.QueryRow(query, provider, providerID).Scan(
		&authProvider.ID, &authProvider.UserID,
		&authProvider.Provider, &authProvider.ProviderID,
		&authProvider.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, fmt.Errorf("failed to find auth provider: %w", err)
	}

	return authProvider, nil
}

// Create links an OAuth provider to a user account.
func (repo *PostgresAuthProviderRepository) Create(
	authProvider *model.UserAuthProvider,
) (*model.UserAuthProvider, error) {
	query := `INSERT INTO user_auth_providers
		(user_id, provider, provider_id)
		VALUES ($1, $2, $3)
		RETURNING id, created_at`

	err := repo.database.QueryRow(
		query,
		authProvider.UserID, authProvider.Provider, authProvider.ProviderID,
	).Scan(&authProvider.ID, &authProvider.CreatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create auth provider: %w", err)
	}

	return authProvider, nil
}

// FindByUserID returns all auth providers linked to a user.
func (repo *PostgresAuthProviderRepository) FindByUserID(
	userID string,
) ([]model.UserAuthProvider, error) {
	query := `SELECT id, user_id, provider, provider_id, created_at
		FROM user_auth_providers WHERE user_id = $1`

	rows, err := repo.database.Query(query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to query auth providers: %w", err)
	}
	defer rows.Close()

	var providers []model.UserAuthProvider
	for rows.Next() {
		var provider model.UserAuthProvider
		if err := rows.Scan(
			&provider.ID, &provider.UserID,
			&provider.Provider, &provider.ProviderID,
			&provider.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan auth provider: %w", err)
		}
		providers = append(providers, provider)
	}

	return providers, rows.Err()
}

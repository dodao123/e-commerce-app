// Package repository provides database access for domain entities.
package repository

import (
	"delivery-app/backend/internal/model"
	"fmt"
)

// Create inserts a new user record and returns it with generated ID.
func (repo *PostgresUserRepository) Create(
	user *model.User,
) (*model.User, error) {
	query := `INSERT INTO users
		(email, email_verified, full_name, avatar_url, locale, role)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, is_active, created_at, updated_at`

	err := repo.database.QueryRow(
		query,
		user.Email, user.EmailVerified, user.FullName,
		user.AvatarURL, user.Locale, user.Role,
	).Scan(&user.ID, &user.IsActive, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return user, nil
}

// UpdateProfile updates the user's mutable profile fields.
func (repo *PostgresUserRepository) UpdateProfile(
	user *model.User,
) error {
	query := `UPDATE users
		SET full_name = $1, avatar_url = $2, locale = $3,
		    email_verified = $4, updated_at = NOW()
		WHERE id = $5`

	_, err := repo.database.Exec(
		query,
		user.FullName, user.AvatarURL, user.Locale,
		user.EmailVerified, user.ID,
	)

	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}

	return nil
}

// UpdateLastLogin sets the last login timestamp to now.
func (repo *PostgresUserRepository) UpdateLastLogin(userID string) error {
	query := `UPDATE users SET last_login_at = NOW() WHERE id = $1`

	_, err := repo.database.Exec(query, userID)
	if err != nil {
		return fmt.Errorf("failed to update last login: %w", err)
	}

	return nil
}

// UpdateRole sets the user's role.
func (repo *PostgresUserRepository) UpdateRole(
	userID string,
	role model.UserRole,
) error {
	query := `UPDATE users SET role = $1, updated_at = NOW() WHERE id = $2`

	_, err := repo.database.Exec(query, role, userID)
	if err != nil {
		return fmt.Errorf("failed to update role: %w", err)
	}

	return nil
}

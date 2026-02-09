// Package repository provides database access for domain entities.
package repository

import (
	"delivery-app/backend/internal/model"
	"fmt"
)

// CreateWithPassword inserts a new user with a password hash.
func (repo *PostgresUserRepository) CreateWithPassword(
	user *model.User,
) (*model.User, error) {
	query := `INSERT INTO users
		(email, email_verified, full_name, avatar_url,
		 locale, role, password_hash)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, is_active, created_at, updated_at`

	err := repo.database.QueryRow(
		query,
		user.Email, user.EmailVerified, user.FullName,
		user.AvatarURL, user.Locale, user.Role,
		user.PasswordHash,
	).Scan(&user.ID, &user.IsActive, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create user with password: %w", err)
	}

	return user, nil
}

// FindByEmailWithPassword finds a user including password_hash.
func (repo *PostgresUserRepository) FindByEmailWithPassword(
	email string,
) (*model.User, error) {
	query := `SELECT id, email, email_verified, full_name, avatar_url,
		locale, role, is_active, last_login_at, created_at, updated_at,
		COALESCE(password_hash, '') as password_hash
		FROM users WHERE email = $1`

	user := &model.User{}
	err := repo.database.QueryRow(query, email).Scan(
		&user.ID, &user.Email, &user.EmailVerified,
		&user.FullName, &user.AvatarURL, &user.Locale,
		&user.Role, &user.IsActive, &user.LastLoginAt,
		&user.CreatedAt, &user.UpdatedAt, &user.PasswordHash,
	)

	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find user: %w", err)
	}

	return user, nil
}

// Package repository provides database access for domain entities.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
	"fmt"
)

// PostgresUserRepository implements UserRepository using PostgreSQL.
type PostgresUserRepository struct {
	database *sql.DB
}

// NewPostgresUserRepository creates a new PostgresUserRepository instance.
func NewPostgresUserRepository(database *sql.DB) *PostgresUserRepository {
	return &PostgresUserRepository{database: database}
}

// FindByEmail finds a user by their email address.
func (repo *PostgresUserRepository) FindByEmail(
	email string,
) (*model.User, error) {
	query := `SELECT id, email, email_verified, full_name, avatar_url,
		locale, role, is_active, last_login_at, created_at, updated_at
		FROM users WHERE email = $1`

	return repo.scanUser(repo.database.QueryRow(query, email))
}

// FindByID finds a user by their UUID.
func (repo *PostgresUserRepository) FindByID(
	id string,
) (*model.User, error) {
	query := `SELECT id, email, email_verified, full_name, avatar_url,
		locale, role, is_active, last_login_at, created_at, updated_at
		FROM users WHERE id = $1`

	return repo.scanUser(repo.database.QueryRow(query, id))
}

// scanUser scans a single row into a User struct.
func (repo *PostgresUserRepository) scanUser(
	row *sql.Row,
) (*model.User, error) {
	user := &model.User{}

	err := row.Scan(
		&user.ID, &user.Email, &user.EmailVerified,
		&user.FullName, &user.AvatarURL, &user.Locale,
		&user.Role, &user.IsActive, &user.LastLoginAt,
		&user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, fmt.Errorf("failed to scan user: %w", err)
	}

	return user, nil
}

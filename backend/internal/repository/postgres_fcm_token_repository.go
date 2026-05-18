// Package repository provides FCM token storage operations.
package repository

import (
	"database/sql"
	"time"
)

// FcmTokenRecord represents a device FCM token for a user.
type FcmTokenRecord struct {
	UserID    string
	Token     string
	UpdatedAt time.Time
}

// PostgresFcmTokenRepository handles FCM token persistence.
type PostgresFcmTokenRepository struct {
	db *sql.DB
}

// NewPostgresFcmTokenRepository creates a new instance.
func NewPostgresFcmTokenRepository(db *sql.DB) *PostgresFcmTokenRepository {
	return &PostgresFcmTokenRepository{db: db}
}

// Upsert saves or updates the FCM token for a user.
func (r *PostgresFcmTokenRepository) Upsert(userID, token string) error {
	_, err := r.db.Exec(`
		INSERT INTO fcm_tokens (user_id, token, updated_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (user_id)
		DO UPDATE SET token = $2, updated_at = NOW()`,
		userID, token)
	return err
}

// GetByUserID returns the FCM token for a specific user.
func (r *PostgresFcmTokenRepository) GetByUserID(userID string) (string, error) {
	var token string
	err := r.db.QueryRow(
		`SELECT token FROM fcm_tokens WHERE user_id = $1`, userID,
	).Scan(&token)
	if err != nil {
		return "", err
	}
	return token, nil
}

// GetDriverTokens returns FCM tokens for all users with the driver role.
func (r *PostgresFcmTokenRepository) GetDriverTokens() ([]string, error) {
	rows, err := r.db.Query(`
		SELECT f.token
		FROM fcm_tokens f
		JOIN users u ON u.id::text = f.user_id
		WHERE u.role = 'driver'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var tokens []string
	for rows.Next() {
		var t string
		if err := rows.Scan(&t); err == nil && t != "" {
			tokens = append(tokens, t)
		}
	}
	return tokens, nil
}

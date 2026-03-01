// Package repository provides notification database operations.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
)

// PostgresNotificationRepository handles notification CRUD.
type PostgresNotificationRepository struct {
	db *sql.DB
}

// NewPostgresNotificationRepository creates a new repo.
func NewPostgresNotificationRepository(
	db *sql.DB,
) *PostgresNotificationRepository {
	return &PostgresNotificationRepository{db: db}
}

// Create inserts a new notification.
func (r *PostgresNotificationRepository) Create(
	n model.Notification,
) error {
	_, err := r.db.Exec(`
		INSERT INTO notifications
		(user_id, title, body, type, ref_id)
		VALUES ($1,$2,$3,$4,$5)`,
		n.UserID, n.Title, n.Body, n.Type, n.RefID)
	return err
}

// ListByUser returns notifications for a user.
func (r *PostgresNotificationRepository) ListByUser(
	userID string,
) ([]model.Notification, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, title, body, type,
		       ref_id, is_read, created_at
		FROM notifications
		WHERE user_id=$1
		ORDER BY created_at DESC
		LIMIT 50`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []model.Notification
	for rows.Next() {
		var n model.Notification
		if err := rows.Scan(
			&n.ID, &n.UserID, &n.Title, &n.Body,
			&n.Type, &n.RefID, &n.IsRead, &n.CreatedAt,
		); err != nil {
			return nil, err
		}
		list = append(list, n)
	}
	return list, nil
}

// MarkRead sets a notification as read.
func (r *PostgresNotificationRepository) MarkRead(
	notifID string,
) error {
	_, err := r.db.Exec(`
		UPDATE notifications
		SET is_read=TRUE WHERE id=$1`, notifID)
	return err
}

// CountUnread returns unread count for a user.
func (r *PostgresNotificationRepository) CountUnread(
	userID string,
) (int, error) {
	var count int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM notifications
		WHERE user_id=$1 AND is_read=FALSE`,
		userID).Scan(&count)
	return count, err
}

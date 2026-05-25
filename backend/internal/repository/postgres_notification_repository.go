// Package repository provides notification database operations.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
	"strings"
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
		(user_id, title, body, type, target_role, ref_id)
		VALUES ($1,$2,$3,$4,$5,$6)`,
		n.UserID, n.Title, n.Body, n.Type, n.TargetRole, n.RefID)
	return err
}

// NotifyNearbyDrivers creates a notification for active drivers within radius.
func (r *PostgresNotificationRepository) NotifyNearbyDrivers(
	order *model.Order, shopLat, shopLng float64,
) error {
	_, err := r.db.Exec(`
		INSERT INTO notifications (user_id, title, body, type, target_role, ref_id)
		SELECT u.id, 'Có đơn hàng mới cần giao!', 'Đơn hàng tới ' || $1, 'driver_pickup', 'driver', $2
		FROM users u
		JOIN shipper_profiles sp ON sp.user_id = u.id
		JOIN delivery_addresses da ON da.id = $3
		WHERE u.role = 'driver' AND u.is_active = TRUE
		  AND earth_distance(ll_to_earth($4, $5), ll_to_earth(sp.latitude, sp.longitude)) <= (sp.operating_radius_km * 1000)
		  AND earth_distance(ll_to_earth(da.latitude, da.longitude), ll_to_earth(sp.latitude, sp.longitude)) <= (sp.operating_radius_km * 1000)`,
		order.ReceiverName, order.ID, order.AddressID, shopLat, shopLng)
	return err
}

// ListByUser returns notifications for a user.
func (r *PostgresNotificationRepository) ListByUser(
	userID string, role string,
) ([]model.Notification, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, title, body, type, target_role,
		       ref_id, is_read, created_at
		FROM notifications
		WHERE user_id=$1 AND target_role=$2
		ORDER BY created_at DESC
		LIMIT 50`, userID, role)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []model.Notification
	for rows.Next() {
		var n model.Notification
		if err := rows.Scan(
			&n.ID, &n.UserID, &n.Title, &n.Body,
			&n.Type, &n.TargetRole, &n.RefID, &n.IsRead, &n.CreatedAt,
		); err != nil {
			return nil, err
		}
		if n.Type == "chat" {
			if strings.Contains(n.Body, "sticker") {
				n.Body = "Đã gửi bạn 1 sticker"
			} else if strings.Contains(n.Body, "uploads/") {
				n.Body = "Đã gửi bạn 1 ảnh"
			}
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
	userID string, role string,
) (int, error) {
	var count int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM notifications
		WHERE user_id=$1 AND target_role=$2 AND is_read=FALSE`,
		userID, role).Scan(&count)
	return count, err
}

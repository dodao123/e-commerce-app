// Package model defines data structures for database entities.
package model

import "time"

// Notification represents an in-app notification.
type Notification struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	Type       string    `json:"type"`
	TargetRole string    `json:"target_role"`
	RefID      string    `json:"ref_id"`
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
}

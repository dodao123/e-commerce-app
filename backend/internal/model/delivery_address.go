// Package model defines data structures for database entities.
package model

import "time"

// DeliveryAddress represents a buyer's shipping address.
type DeliveryAddress struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	ReceiverName  string    `json:"receiver_name"`
	Phone         string    `json:"phone"`
	Province      string    `json:"province"`
	District      string    `json:"district"`
	Ward          string    `json:"ward"`
	DetailAddress string    `json:"detail_address"`
	Latitude      float64   `json:"lat"`
	Longitude     float64   `json:"lng"`
	IsDefault     bool      `json:"is_default"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

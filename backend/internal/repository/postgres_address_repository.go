// Package repository provides PostgreSQL address operations.
package repository

import (
	"database/sql"
	"delivery-app/backend/internal/model"
)

// PostgresAddressRepository implements address storage.
type PostgresAddressRepository struct {
	db *sql.DB
}

// NewPostgresAddressRepository creates a new instance.
func NewPostgresAddressRepository(
	db *sql.DB,
) *PostgresAddressRepository {
	return &PostgresAddressRepository{db: db}
}

// Create inserts a new address.
func (r *PostgresAddressRepository) Create(
	addr model.DeliveryAddress,
) (*model.DeliveryAddress, error) {
	err := r.db.QueryRow(`
		INSERT INTO delivery_addresses
		(user_id, receiver_name, phone, province,
		 district, ward, detail_address, is_default)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
		RETURNING id, created_at`,
		addr.UserID, addr.ReceiverName, addr.Phone,
		addr.Province, addr.District, addr.Ward,
		addr.DetailAddress, addr.IsDefault,
	).Scan(&addr.ID, &addr.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &addr, nil
}

// ListByUser returns all addresses for a user.
func (r *PostgresAddressRepository) ListByUser(
	userID string,
) ([]model.DeliveryAddress, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, receiver_name, phone,
		       province, district, ward, detail_address,
		       is_default, created_at
		FROM delivery_addresses
		WHERE user_id=$1
		ORDER BY is_default DESC, created_at DESC`,
		userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []model.DeliveryAddress
	for rows.Next() {
		var a model.DeliveryAddress
		if err := rows.Scan(
			&a.ID, &a.UserID, &a.ReceiverName,
			&a.Phone, &a.Province, &a.District,
			&a.Ward, &a.DetailAddress,
			&a.IsDefault, &a.CreatedAt,
		); err != nil {
			return nil, err
		}
		list = append(list, a)
	}
	return list, nil
}

// GetByID returns a single address.
func (r *PostgresAddressRepository) GetByID(
	id string,
) (*model.DeliveryAddress, error) {
	var a model.DeliveryAddress
	err := r.db.QueryRow(`
		SELECT id, user_id, receiver_name, phone,
		       province, district, ward, detail_address,
		       is_default, created_at
		FROM delivery_addresses WHERE id=$1`, id,
	).Scan(&a.ID, &a.UserID, &a.ReceiverName,
		&a.Phone, &a.Province, &a.District,
		&a.Ward, &a.DetailAddress,
		&a.IsDefault, &a.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &a, nil
}

// Delete removes an address.
func (r *PostgresAddressRepository) Delete(
	id string,
) error {
	_, err := r.db.Exec(
		`DELETE FROM delivery_addresses WHERE id=$1`, id)
	return err
}

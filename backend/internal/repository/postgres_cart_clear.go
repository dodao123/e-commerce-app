// Package repository provides cart cleanup operations.
package repository

// ClearCart removes all items for a user.
func (repo *PostgresCartRepository) ClearCart(
	userID string,
) error {
	_, err := repo.database.Exec(
		`DELETE FROM cart_items WHERE user_id = $1`,
		userID)
	return err
}

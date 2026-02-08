// Package database provides PostgreSQL connection management.
package database

import (
	"database/sql"
	"delivery-app/backend/internal/config"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

// PostgresDB wraps the SQL database connection pool.
type PostgresDB struct {
	Pool *sql.DB
}

// NewPostgresDB creates a new PostgreSQL connection pool.
func NewPostgresDB(dbConfig *config.DatabaseConfig) (*PostgresDB, error) {
	connectionString := dbConfig.ConnectionString()

	pool, err := sql.Open("postgres", connectionString)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Configure connection pool
	pool.SetMaxOpenConns(25)
	pool.SetMaxIdleConns(5)

	// Verify the connection
	if err := pool.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Printf("✅ Connected to PostgreSQL: %s:%s/%s",
		dbConfig.Host, dbConfig.Port, dbConfig.DBName,
	)

	return &PostgresDB{Pool: pool}, nil
}

// Close terminates the database connection pool.
func (db *PostgresDB) Close() error {
	if db.Pool != nil {
		return db.Pool.Close()
	}
	return nil
}

// HealthCheck verifies the database connection is alive.
func (db *PostgresDB) HealthCheck() error {
	return db.Pool.Ping()
}

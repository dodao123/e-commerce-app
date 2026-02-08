// Package config loads application configuration from environment variables.
package config

import (
	"fmt"
	"os"
)

// Config holds all application configuration values.
type Config struct {
	ServerPort string
	Database   DatabaseConfig
}

// DatabaseConfig holds PostgreSQL connection parameters.
type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

// Load reads configuration from environment variables.
func Load() *Config {
	return &Config{
		ServerPort: getEnv("SERVER_PORT", "8080"),
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", ""),
			DBName:   getEnv("DB_NAME", "delivery"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
	}
}

// ConnectionString returns the PostgreSQL DSN string.
func (db *DatabaseConfig) ConnectionString() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		db.Host, db.Port, db.User, db.Password, db.DBName, db.SSLMode,
	)
}

// getEnv reads an environment variable or returns a default value.
func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

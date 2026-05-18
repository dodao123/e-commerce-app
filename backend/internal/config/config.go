// Package config loads application configuration from environment variables.
package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config holds all application configuration values.
type Config struct {
	ServerPort string
	Database   DatabaseConfig
	Auth       AuthConfig
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

// AuthConfig holds authentication-related configuration.
type AuthConfig struct {
	JWTSecret      string
	JWTExpiryHours int
	GoogleClientID string
	FacebookAppID  string
	FacebookSecret string
}

// Load reads configuration from environment variables.
func Load() *Config {
	jwtExpiry, _ := strconv.Atoi(getEnv("JWT_EXPIRY_HOURS", "24"))

	return &Config{
		ServerPort: getEnv("SERVER_PORT", "8081"),
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", ""),
			DBName:   getEnv("DB_NAME", "delivery"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
		Auth: AuthConfig{
			JWTSecret:      getEnv("JWT_SECRET", ""),
			JWTExpiryHours: jwtExpiry,
			GoogleClientID: getEnv("GOOGLE_CLIENT_ID", ""),
			FacebookAppID:  getEnv("FB_APP_ID", ""),
			FacebookSecret: getEnv("FB_APP_SECRET", ""),
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

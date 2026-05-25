// Package migration provides database schema migration scripts.
package migration

// CreateUsersTableSQL creates the users table for storing user profiles.
// Designed for ecommerce with role-based access (buyer/seller/driver/admin).
const CreateUsersTableSQL = `
CREATE TABLE IF NOT EXISTS users (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email          VARCHAR(255) NOT NULL UNIQUE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    full_name      VARCHAR(255) NOT NULL,
    avatar_url     TEXT DEFAULT '',
    locale         VARCHAR(10) DEFAULT '',
    role           VARCHAR(20) NOT NULL DEFAULT 'unselected',
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at  TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users (role);
`

// CreateAuthProvidersTableSQL creates the user_auth_providers table.
// Supports multiple OAuth providers per user (Google, Facebook, Apple, etc.).
const CreateAuthProvidersTableSQL = `
CREATE TABLE IF NOT EXISTS user_auth_providers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider    VARCHAR(20) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_provider_account UNIQUE (provider, provider_id)
);

CREATE INDEX IF NOT EXISTS idx_auth_provider_user
    ON user_auth_providers (user_id);
CREATE INDEX IF NOT EXISTS idx_auth_provider_lookup
    ON user_auth_providers (provider, provider_id);
`

// Package migration provides database schema migration scripts.
package migration

// AddShopAIAssistantSQL adds the ai_assistant_enabled column to shops table.
const AddShopAIAssistantSQL = `
ALTER TABLE shops ADD COLUMN IF NOT EXISTS ai_assistant_enabled BOOLEAN NOT NULL DEFAULT FALSE;
`

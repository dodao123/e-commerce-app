// Package migration provides database schema migration scripts.
package migration

// CreateNotificationsTableSQL creates the notifications table.
const CreateNotificationsTableSQL = `
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    type VARCHAR(50) NOT NULL DEFAULT 'order',
    ref_id VARCHAR(100) DEFAULT '',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notif_user
    ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_unread
    ON notifications(user_id, is_read);
`

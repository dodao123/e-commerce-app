// Package migration provides database schema migration scripts.
package migration

// AlterNotificationsAddTargetRoleSQL adds target_role to notifications.
const AlterNotificationsAddTargetRoleSQL = `
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS target_role VARCHAR(20) DEFAULT '';
`

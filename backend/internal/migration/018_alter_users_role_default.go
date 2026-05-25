package migration

// AlterUsersRoleDefaultSQL alters the default value of the role column to 'unselected'.
const AlterUsersRoleDefaultSQL = `
ALTER TABLE users ALTER COLUMN role SET DEFAULT 'unselected';
`

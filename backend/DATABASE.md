# Database Reset Guide

## Quick Reset (Recommended)

Chạy lệnh SQL này trực tiếp trong PostgreSQL client (pgAdmin, DBeaver, psql):

```sql
-- Drop all tables
DROP TABLE IF EXISTS shops CASCADE;
DROP TABLE IF EXISTS user_auth_providers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Recreate schema (if needed)
CREATE SCHEMA IF NOT EXISTS public;
```

Sau đó restart server để migrations tự chạy:

```bash
cd backend
.\server.exe
```

## Alternative: Use Reset Script

```bash
cd backend
go run ./cmd/reset_db/main.go
```

## Manual Steps

1. **Connect to PostgreSQL:**
   - Host: 180.93.139.29
   - Port: 26952
   - Database: buyer_app

2. **Run DROP commands:**
   ```sql
   DROP TABLE IF EXISTS shops CASCADE;
   DROP TABLE IF EXISTS user_auth_providers CASCADE;
   DROP TABLE IF EXISTS users CASCADE;
   ```

3. **Restart backend server** - migrations will auto-run

4. **Clear Flutter app data:**
   - Settings → Apps → Delivery App → Clear Data
   - Or: `flutter clean && flutter run`

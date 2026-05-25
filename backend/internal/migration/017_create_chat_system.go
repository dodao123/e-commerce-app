// Package migration provides database schema migration scripts.
package migration

// CreateChatSystemTableSQL creates the chat_rooms and chat_messages tables.
const CreateChatSystemTableSQL = `
CREATE TABLE IF NOT EXISTS chat_rooms (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_type            VARCHAR(30) NOT NULL, -- 'customer_shop', 'shipper_customer', 'shipper_shop'
    customer_id          UUID REFERENCES users(id) ON DELETE SET NULL,
    shop_id              UUID REFERENCES shops(id) ON DELETE CASCADE,
    shipper_id           UUID REFERENCES users(id) ON DELETE SET NULL,
    associated_order_id  UUID REFERENCES orders(id) ON DELETE SET NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_customer_shop ON chat_rooms (customer_id, shop_id) WHERE room_type = 'customer_shop';
CREATE UNIQUE INDEX IF NOT EXISTS uq_shipper_customer ON chat_rooms (shipper_id, customer_id) WHERE room_type = 'shipper_customer';
CREATE UNIQUE INDEX IF NOT EXISTS uq_shipper_shop ON chat_rooms (shipper_id, shop_id) WHERE room_type = 'shipper_shop';

CREATE TABLE IF NOT EXISTS chat_messages (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id      UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_role  VARCHAR(20) NOT NULL, -- 'customer', 'shop_staff', 'shipper', 'ai_assistant'
    message_type VARCHAR(20) NOT NULL DEFAULT 'text', -- 'text', 'image'
    content      TEXT NOT NULL,
    is_read      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_rooms_customer ON chat_rooms (customer_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_shop ON chat_rooms (shop_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_shipper ON chat_rooms (shipper_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room ON chat_messages (room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages (created_at DESC);
`

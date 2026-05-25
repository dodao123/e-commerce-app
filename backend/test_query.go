package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "host=localhost port=5432 user=postgres password=postgres dbname=delivery_app sslmode=disable")
	if err != nil {
		log.Fatalf("Failed to open db: %v", err)
	}
	defer db.Close()

	// Get a user ID that has rooms
	var userID string
	err = db.QueryRow("SELECT customer_id FROM chat_rooms WHERE customer_id IS NOT NULL LIMIT 1").Scan(&userID)
	if err != nil {
		log.Fatalf("Failed to find a user: %v", err)
	}
	fmt.Printf("Testing query for userID: %s\n", userID)

	query := `
		SELECT r.id, r.room_type, r.customer_id, r.shop_id, r.shipper_id, r.associated_order_id, r.created_at, r.updated_at,
		       COALESCE(s.shop_name, u.full_name, '') as partner_name,
		       COALESCE(seller.avatar_url, u.avatar_url, '') as partner_avatar,
		       COALESCE((SELECT content FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_message,
		       COALESCE((SELECT message_type FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), 'text') as last_msg_type,
		       COALESCE((SELECT sender_id::text FROM chat_messages WHERE room_id = r.id ORDER BY created_at DESC LIMIT 1), '') as last_msg_sender_id,
		       (SELECT COUNT(*) FROM chat_messages WHERE room_id = r.id AND sender_id != $1 AND is_read = false) as unread_count
		FROM chat_rooms r
		LEFT JOIN shops s ON r.shop_id = s.id AND r.room_type = 'customer_shop'
		LEFT JOIN users seller ON s.seller_id = seller.id AND r.room_type = 'customer_shop'
		LEFT JOIN users u ON (u.id = r.shipper_id AND r.room_type = 'shipper_customer') 
		                  OR (u.id = r.customer_id AND r.room_type = 'shipper_customer')
		WHERE (r.customer_id = $1 OR r.shipper_id = $1)
		  AND EXISTS (SELECT 1 FROM chat_messages WHERE room_id = r.id)
		ORDER BY r.updated_at DESC
	`

	rows, err := db.QueryContext(context.Background(), query, userID)
	if err != nil {
		log.Fatalf("Query failed: %v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, roomType, partnerName, partnerAvatar, lastMessage, lastMsgType, lastMsgSenderID string
		var customerID, shopID, shipperID, associatedOrderID sql.NullString
		var createdAt, updatedAt string
		var unreadCount int

		err := rows.Scan(
			&id, &roomType, &customerID, &shopID, &shipperID, &associatedOrderID, &createdAt, &updatedAt,
			&partnerName, &partnerAvatar, &lastMessage, &lastMsgType, &lastMsgSenderID, &unreadCount,
		)
		if err != nil {
			log.Fatalf("Scan failed: %v", err)
		}
		fmt.Printf("Room %s: last message is type %s, content: %s\n", id, lastMsgType, lastMessage)
	}
	fmt.Println("Success!")
}

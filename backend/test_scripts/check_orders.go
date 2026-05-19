package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "postgres://postgres:postgres@localhost:5432/delivery_app?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT id, user_id, address_id, status, created_at FROM orders ORDER BY created_at DESC LIMIT 5")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, userID, addrID, status, created string
		rows.Scan(&id, &userID, &addrID, &status, &created)
		fmt.Printf("Order: %s | User: %s | Addr: %s | Status: %s | Date: %s\n", id, userID, addrID, status, created)
	}
}

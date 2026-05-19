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

	shipperID := "f42f6048-b0a5-48bd-b7bb-3a131b4028ce"
	err = db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	if err != nil {
		log.Fatal("Get shipper ID: ", err)
	}

	rows, err := db.Query(`
		SELECT id, status
		FROM orders
		WHERE shipper_id = $1 
	`, shipperID)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	shipping := 0
	delivered := 0
	for rows.Next() {
		var id, status string
		if err := rows.Scan(&id, &status); err != nil {
			log.Fatal(err)
		}
		if status == "shipping" {
			shipping++
		} else if status == "delivered" {
			delivered++
		}
	}
	fmt.Printf("DB Stats for Shipper %s: Shipping=%d, Delivered=%d\n", shipperID, shipping, delivered)
}

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

	rows, err := db.Query("SELECT id, status FROM orders WHERE shipper_id IS NOT NULL")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	shipping := 0
	delivered := 0
	pickingUp := 0
	for rows.Next() {
		var id, status string
		if err := rows.Scan(&id, &status); err != nil {
			log.Fatal(err)
		}
		if status == "shipping" {
			shipping++
		} else if status == "delivered" {
			delivered++
		} else if status == "finding_driver" {
			pickingUp++
		}
	}
	fmt.Printf("DB Stats for assigned orders: PickingUp=%d, Shipping=%d, Delivered=%d\n", pickingUp, shipping, delivered)
}

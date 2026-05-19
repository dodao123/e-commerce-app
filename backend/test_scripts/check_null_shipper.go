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

	rows, _ := db.Query("SELECT id, status, shipper_id FROM orders WHERE status IN ('shipping', 'delivered')")
	for rows.Next() {
		var id, status string
		var shipperID sql.NullString
		rows.Scan(&id, &status, &shipperID)
		fmt.Printf("Order %s: Status=%s, ShipperID=%v\n", id, status, shipperID.String)
	}
}

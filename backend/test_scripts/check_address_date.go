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

	rows, err := db.Query("SELECT id, receiver_name, latitude, longitude, created_at FROM delivery_addresses")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, name, created string
		var lat, lng float64
		rows.Scan(&id, &name, &lat, &lng, &created)
		fmt.Printf("Addr: %s | %s | %f, %f | %s\n", id, name, lat, lng, created)
	}
}

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

	rows, err := db.Query("SELECT user_id, full_name, vehicle_type, license_plate, updated_at FROM shipper_profiles")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, name, vtype, plate, updated string
		rows.Scan(&id, &name, &vtype, &plate, &updated)
		fmt.Printf("Profile: %s | %s | %s | %s | %s\n", id, name, vtype, plate, updated)
	}
}

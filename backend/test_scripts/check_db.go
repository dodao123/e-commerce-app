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

	var userID string
	err = db.QueryRow("SELECT id FROM users WHERE email = 'doddmts@gmail.com'").Scan(&userID)
	if err != nil {
		log.Fatal("User not found:", err)
	}

	fmt.Println("User ID:", userID)

	rows, err := db.Query("SELECT full_name, vehicle_type, license_plate FROM shipper_profiles WHERE user_id = $1", userID)
	if err != nil {
		log.Fatal("Query error:", err)
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		count++
		var name, vtype, plate string
		if err := rows.Scan(&name, &vtype, &plate); err != nil {
			log.Fatal("Scan error:", err)
		}
		fmt.Printf("Profile found: Name=%s, Vehicle=%s, Plate=%s\n", name, vtype, plate)
	}
	
	if count == 0 {
		fmt.Println("NO PROFILE FOUND IN DATABASE!")
	}
}

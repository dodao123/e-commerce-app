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

	fmt.Println("--- USERS ---")
	rows, err := db.Query("SELECT id, email, role FROM users")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	users := map[string]struct{ Email, Role string }{}
	for rows.Next() {
		var id, email, role string
		rows.Scan(&id, &email, &role)
		users[id] = struct{ Email, Role string }{email, role}
	}

	fmt.Println("\n--- SHOP ADDRESSES (Sellers) ---")
	shopRows, err := db.Query("SELECT seller_id, name, latitude, longitude, detail_address FROM shops")
	if err == nil {
		defer shopRows.Close()
		for shopRows.Next() {
			var sellerID, name, detail string
			var lat, lng float64
			shopRows.Scan(&sellerID, &name, &lat, &lng, &detail)
			email := users[sellerID].Email
			fmt.Printf("Shop Name: %s | Seller Email: %s | Lat/Lng: (%.6f, %.6f) | Detail: %s\n", name, email, lat, lng, detail)
		}
	}

	fmt.Println("\n--- SHIPPER PROFILES (Drivers) ---")
	shipperRows, err := db.Query("SELECT user_id, full_name, latitude, longitude, operating_radius_km FROM shipper_profiles")
	if err == nil {
		defer shipperRows.Close()
		for shipperRows.Next() {
			var userID, name string
			var lat, lng, radius float64
			shipperRows.Scan(&userID, &name, &lat, &lng, &radius)
			email := users[userID].Email
			fmt.Printf("Shipper Name: %s | Email: %s | Lat/Lng: (%.6f, %.6f) | Radius: %.1f km\n", name, email, lat, lng, radius)
		}
	}

	fmt.Println("\n--- DELIVERY ADDRESSES (Buyers/Default Addresses) ---")
	addrRows, err := db.Query("SELECT user_id, receiver_name, latitude, longitude, detail_address FROM delivery_addresses")
	if err == nil {
		defer addrRows.Close()
		for addrRows.Next() {
			var userID, name, detail string
			var lat, lng float64
			addrRows.Scan(&userID, &name, &lat, &lng, &detail)
			email := users[userID].Email
			fmt.Printf("Receiver: %s | Email: %s | Lat/Lng: (%.6f, %.6f) | Detail: %s\n", name, email, lat, lng, detail)
		}
	}
}

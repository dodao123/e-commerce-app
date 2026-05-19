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

	var lat, lng float64
	err = db.QueryRow("SELECT latitude, longitude FROM delivery_addresses WHERE id=$1", "c4beaeec-7cf9-4c63-b5d5-31ea5c55e7b1").Scan(&lat, &lng)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Order Address c4beaeec: %f, %f\n", lat, lng)
	
	// Check the shop of this order
	var shopLat, shopLng float64
	err = db.QueryRow("SELECT latitude, longitude FROM shops WHERE seller_id = (SELECT seller_id FROM orders WHERE id='a3ab7076-8c39-4a22-a137-2bd5b8258169')").Scan(&shopLat, &shopLng)
	if err != nil {
		fmt.Printf("Shop error: %v\n", err)
	} else {
		fmt.Printf("Shop coordinates: %f, %f\n", shopLat, shopLng)
	}

	// Check distance from shipper to both
	var d1, d2 float64
	err = db.QueryRow(`
		SELECT 
		  earth_distance(ll_to_earth($1, $2), ll_to_earth(21.038278, 105.742989)) / 1000.0,
		  earth_distance(ll_to_earth($3, $4), ll_to_earth(21.038278, 105.742989)) / 1000.0
	`, lat, lng, shopLat, shopLng).Scan(&d1, &d2)
	fmt.Printf("Distance Shipper<->Customer: %.2f km\n", d1)
	fmt.Printf("Distance Shipper<->Shop: %.2f km\n", d2)
}

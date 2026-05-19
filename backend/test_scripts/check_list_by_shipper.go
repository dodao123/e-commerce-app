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

	// Shipper ID for dodao2005@gmail.com
	shipperID := "f42f6048-b0a5-48bd-b7bb-3a131b4028ce" // wait, dodao2005@gmail.com is seller. Who is shipper?
	// Let's get shipper ID by email
	err = db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	if err != nil {
		log.Fatal("Get shipper ID: ", err)
	}
	fmt.Println("Shipper ID:", shipperID)

	var radius float64
	var spLat, spLng float64
	err = db.QueryRow("SELECT operating_radius_km, latitude, longitude FROM shipper_profiles WHERE user_id=$1", shipperID).Scan(&radius, &spLat, &spLng)
	if err != nil {
		log.Fatal("Get shipper profile: ", err)
	}
	fmt.Printf("Shipper profile: Radius=%.2f, Lat=%f, Lng=%f\n", radius, spLat, spLng)

	rows, err := db.Query(`
		SELECT DISTINCT o.id, o.status, s.latitude, s.longitude, da.latitude, da.longitude
		FROM orders o
		LEFT JOIN order_items oi ON oi.order_id = o.id
		LEFT JOIN shops s ON s.id = oi.shop_id
		LEFT JOIN delivery_addresses da ON da.id = o.address_id
		WHERE o.status = 'finding_driver'
	`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, status string
		var sLat, sLng, cLat, cLng float64
		if err := rows.Scan(&id, &status, &sLat, &sLng, &cLat, &cLng); err != nil {
			log.Fatal(err)
		}
		
		var distShop, distCust float64
		db.QueryRow("SELECT earth_distance(ll_to_earth($1, $2), ll_to_earth($3, $4)) / 1000", sLat, sLng, spLat, spLng).Scan(&distShop)
		db.QueryRow("SELECT earth_distance(ll_to_earth($1, $2), ll_to_earth($3, $4)) / 1000", cLat, cLng, spLat, spLng).Scan(&distCust)

		fmt.Printf("Order %s: distShop=%.2f km, distCust=%.2f km\n", id, distShop, distCust)
	}
}

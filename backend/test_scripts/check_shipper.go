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

	shipperID := ""
	err = db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	if err != nil {
		log.Fatal("Get shipper ID: ", err)
	}

	var radius float64
	var spLat, spLng float64
	err = db.QueryRow("SELECT operating_radius_km, latitude, longitude FROM shipper_profiles WHERE user_id=$1", shipperID).Scan(&radius, &spLat, &spLng)
	if err != nil {
		log.Fatal("Get shipper profile: ", err)
	}
	fmt.Printf("Shipper profile: Radius=%.2f, Lat=%f, Lng=%f\n", radius, spLat, spLng)
}

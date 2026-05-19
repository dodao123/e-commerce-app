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

	var id, name, cccd string
	var lat, lng float64
	err = db.QueryRow("SELECT id, shop_name, national_id_number, latitude, longitude FROM shops WHERE id='b5c39542-e107-4bf7-8c52-ea2f895cb59b'").Scan(&id, &name, &cccd, &lat, &lng)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Shop: %s | %s | CCCD: %s | Lat: %f | Lng: %f\n", id, name, cccd, lat, lng)
}

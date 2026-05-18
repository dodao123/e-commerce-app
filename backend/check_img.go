package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "host=localhost port=5432 user=postgres password=1 dbname=delivery_app sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT order_id, product_name, product_image FROM order_items LIMIT 5;")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, name, img string
		if err := rows.Scan(&id, &name, &img); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("OrderID: %s, Name: %s, Image: %s\n", id, name, img)
	}
}

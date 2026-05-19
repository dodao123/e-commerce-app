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

	// 1. Shipper Orders
	var shipperID string
	db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	rows1, _ := db.Query("SELECT status FROM orders WHERE shipper_id = $1", shipperID)
	shipperCounts := make(map[string]int)
	for rows1.Next() {
		var status string
		rows1.Scan(&status)
		shipperCounts[status]++
	}
	rows1.Close()
	fmt.Printf("Shipper (%s): %v\n", shipperID, shipperCounts)

	// 2. Buyer Orders
	var buyerID string
	db.QueryRow("SELECT id FROM users WHERE email='dodao9009@gmail.com'").Scan(&buyerID)
	rows2, _ := db.Query("SELECT status FROM orders WHERE user_id = $1", buyerID)
	buyerCounts := make(map[string]int)
	for rows2.Next() {
		var status string
		rows2.Scan(&status)
		buyerCounts[status]++
	}
	rows2.Close()
	fmt.Printf("Buyer (%s): %v\n", buyerID, buyerCounts)
	
	// 3. ALL orders
	rows3, _ := db.Query("SELECT status FROM orders")
	allCounts := make(map[string]int)
	for rows3.Next() {
		var status string
		rows3.Scan(&status)
		allCounts[status]++
	}
	rows3.Close()
	fmt.Printf("ALL Orders: %v\n", allCounts)
}

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

	rows, _ := db.Query("SELECT email, role FROM users WHERE role='driver'")
	for rows.Next() {
		var email, role string
		rows.Scan(&email, &role)
		fmt.Printf("Driver: %s\n", email)
	}
}

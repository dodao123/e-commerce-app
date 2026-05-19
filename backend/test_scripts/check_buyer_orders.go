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

	userID := ""
	err = db.QueryRow("SELECT id FROM users WHERE email='dodao2005@gmail.com'").Scan(&userID)
	if err != nil {
		log.Fatal(err)
	}

	rows, err := db.Query(`
		SELECT id, status
		FROM orders
		WHERE user_id = $1 
	`, userID)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	counts := make(map[string]int)
	for rows.Next() {
		var id, status string
		if err := rows.Scan(&id, &status); err != nil {
			log.Fatal(err)
		}
		counts[status]++
	}
	fmt.Printf("DB Stats for Buyer %s: %v\n", userID, counts)
}

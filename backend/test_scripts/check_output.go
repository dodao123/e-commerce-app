package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"

	"delivery-app/backend/internal/repository"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "postgres://postgres:postgres@localhost:5432/delivery_app?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	repo := repository.NewPostgresOrderRepository(db)

	shipperID := "e0722c18-b657-4fd1-9240-be9b5178faec"

	orders, err := repo.ListByShipper(shipperID, 6.0)
	if err != nil {
		log.Fatal(err)
	}

	out, _ := json.MarshalIndent(orders, "", "  ")
	fmt.Println(string(out))
}

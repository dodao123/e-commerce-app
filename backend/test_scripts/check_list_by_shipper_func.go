package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
	"delivery-app/backend/internal/repository"
)

func main() {
	db, err := sql.Open("postgres", "postgres://postgres:postgres@localhost:5432/delivery_app?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	repo := repository.NewPostgresOrderRepository(db)
	
	shipperID := ""
	err = db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	if err != nil {
		log.Fatal(err)
	}

	orders, err := repo.ListByShipper(shipperID, 6.0)
	if err != nil {
		log.Fatal(err)
	}

	shipping := 0
	delivered := 0
	pickingUp := 0
	for _, o := range orders {
		if o.Status == "shipping" {
			shipping++
		} else if o.Status == "delivered" {
			delivered++
		} else if o.Status == "finding_driver" {
			pickingUp++
		}
	}
	fmt.Printf("ListByShipper results: PickingUp=%d, Shipping=%d, Delivered=%d\n", pickingUp, shipping, delivered)
}

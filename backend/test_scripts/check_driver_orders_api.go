package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"database/sql"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/service"
	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "postgres://postgres:postgres@localhost:5432/delivery_app?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	orderRepo := repository.NewPostgresOrderRepository(db)
	orderService := service.NewOrderService(orderRepo, nil, 6.0)

	var shipperID string
	err = db.QueryRow("SELECT id FROM users WHERE email='doddmts@gmail.com'").Scan(&shipperID)
	
	orders, err := orderService.ListDriverOrders(shipperID)
	if err != nil {
		log.Fatal(err)
	}

	out, _ := json.MarshalIndent(orders, "", "  ")
	fmt.Println(string(out))
}

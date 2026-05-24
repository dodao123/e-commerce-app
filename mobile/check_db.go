package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	connStr := "postgresql://postgres:1@localhost:5432/delivery_app?sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	fmt.Println("--- USERS ---")
	rows, err := db.Query("SELECT id, email, full_name, role, avatar_url FROM users")
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		var id, email, fullName, role, avatarUrl string
		rows.Scan(&id, &email, &fullName, &role, &avatarUrl)
		fmt.Printf("ID: %s | Email: %s | Name: %s | Role: %s | Avatar: %s\n", id, email, fullName, role, avatarUrl)
	}
	rows.Close()

	fmt.Println("\n--- SHOPS ---")
	rows, err = db.Query("SELECT id, seller_id, shop_name, is_active, is_verified, email, phone FROM shops")
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		var id, sellerId, shopName, email, phone string
		var isActive, isVerified bool
		rows.Scan(&id, &sellerId, &shopName, &isActive, &isVerified, &email, &phone)
		fmt.Printf("ID: %s | SellerID: %s | Name: %s | Active: %t | Verified: %t | Email: %s | Phone: %s\n", id, sellerId, shopName, isActive, isVerified, email, phone)
	}
	rows.Close()

	fmt.Println("\n--- PRODUCTS FROM GIÀY ---")
	rows, err = db.Query(`
		SELECT p.id, p.name, p.shop_id, s.shop_name, COALESCE(u.avatar_url, '') 
		FROM products p 
		JOIN shops s ON p.shop_id = s.id 
		LEFT JOIN users u ON s.seller_id = u.id
		WHERE s.shop_name ILIKE '%giày%' OR p.name ILIKE '%giày%';
	`)
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		var pid, pname, shopId, shopName, avatarUrl string
		rows.Scan(&pid, &pname, &shopId, &shopName, &avatarUrl)
		fmt.Printf("ProdID: %s | Name: %s | ShopID: %s | ShopName: %s | Avatar: %s\n", pid, pname, shopId, shopName, avatarUrl)
	}
	rows.Close()
}

package main

import (
	"context"
	"database/sql"
	"delivery-app/backend/internal/config"
	"delivery-app/backend/internal/database"
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/repository"
	"delivery-app/backend/internal/service"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	cfg := config.Load()
	db, err := database.NewPostgresDB(&cfg.Database)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("🌱 Seeding database...")

	// 1. Create Users
	customerID := uuid.New().String()
	sellerID := uuid.New().String()

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), 10)
	passHash := string(hashedPassword)

	_, err = db.Pool.Exec(`
		INSERT INTO users (id, full_name, email, password_hash, role, avatar_url)
		VALUES 
			($1, 'Nguyen Van Customer', 'customer@test.com', $3, 'customer', 'https://api.dicebear.com/7.x/adventurer/svg?seed=customer'),
			($2, 'Tran Thi Seller', 'shop@test.com', $3, 'seller', 'https://api.dicebear.com/7.x/adventurer/svg?seed=seller')
		ON CONFLICT DO NOTHING
	`, customerID, sellerID, passHash)
	if err != nil {
		log.Fatalf("Failed to seed users: %v", err)
	}

	// 2. Create Shop
	shopID := uuid.New().String()
	_, err = db.Pool.Exec(`
		INSERT INTO shops (id, seller_id, shop_name, description, phone, avatar_url, latitude, longitude, ai_assistant_enabled)
		VALUES ($1, $2, 'Goc Indie Cafe', 'Quan ca phe phong cach Indie Folk moc mac, am cung', '0912345678', 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=200&auto=format&fit=crop', 10.776, 106.700, true)
		ON CONFLICT DO NOTHING
	`, shopID, sellerID)
	if err != nil {
		log.Fatalf("Failed to seed shop: %v", err)
	}

	// 3. Create Products
	products := []struct {
		Name        string
		Description string
		Price       float64
		Category    string
	}{
		{"Ca phe sua da", "Ca phe phin dam da huong vi Viet Nam hoa quyen cung sua dac ngọt ngao.", 29000, "Drinks"},
		{"Bac xiu nong", "Ca phe bac xiu am ap phu hop cho buoi sang thanh tinh.", 32000, "Drinks"},
		{"Tra sua chan chau duong den", "Tra sua thom ngot beo ngay kem tran chau duong den dai gion.", 45000, "Drinks"},
		{"Banh mi thit nuong Special", "Banh mi gion rum kep thit heo nuong thom lung va do chua hanh ngo.", 25000, "Food"},
		{"Croissant bo phap", "Banh sung bo thom huong bo tui Phap.", 35000, "Food"},
	}

	productRepo := repository.NewPostgresProductRepository(db.Pool)
	embRepo := repository.NewPostgresEmbeddingRepository(db.Pool)

	geminiKey := os.Getenv("GEMINI_API_KEY")
	var embSvc *service.EmbeddingService
	if geminiKey != "" {
		embSvc = service.NewEmbeddingService(geminiKey)
	}

	for _, p := range products {
		pID := uuid.New().String()
		optionsJSON, _ := json.Marshal([]interface{}{})
		imagesJSON, _ := json.Marshal([]string{"https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop"})

		_, err = db.Pool.Exec(`
			INSERT INTO products (id, shop_id, name, description, price, images, options, rating, rating_count, category, is_available)
			VALUES ($1, $2, $3, $4, $5, $6, $7, 5.0, 10, $8, true)
		`, pID, shopID, p.Name, p.Description, p.Price, string(imagesJSON), string(optionsJSON), p.Category)
		if err != nil {
			log.Fatalf("Failed to seed product %s: %v", p.Name, err)
		}

		// Generate embedding vector if Gemini is enabled
		if embSvc != nil {
			textToEmbed := fmt.Sprintf("name: %s. description: %s. category: %s", p.Name, p.Description, p.Category)
			vector, err := embSvc.Embed(context.Background(), textToEmbed)
			if err == nil {
				_ = embRepo.SaveEmbedding(context.Background(), &model.ProductEmbedding{
					ProductID:    pID,
					Embedding:    vector,
					ModelVersion: "gemini-embedding-001",
				})
			}
		}
	}

	log.Println("✅ Database seeded successfully!")
	log.Println("🔑 Accounts created:")
	log.Println("   - Customer: customer@test.com / password123")
	log.Println("   - Shop Seller: shop@test.com / password123")
}

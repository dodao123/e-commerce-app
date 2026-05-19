package main

import (
	"delivery-app/backend/internal/model"
	"delivery-app/backend/internal/service"
	"fmt"
	"log"
	"os"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "supersecretkey" // Default in envloader if missing
	}
	authSvc := service.NewAuthService(nil, nil, nil) // We only need it for GenerateToken, but it requires db. Let's just use raw jwt.
}

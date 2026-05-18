// Package service provides Firebase Cloud Messaging push notification logic.
package service

import (
	"context"
	"log"
	"os"
	"path/filepath"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// FcmService sends push notifications via Firebase Cloud Messaging.
type FcmService struct {
	client *messaging.Client
}

// newFcmService initializes the Firebase Admin SDK with the service account key.
func newFcmService() *FcmService {
	// Use working directory (server is always run from backend root)
	wd, err := os.Getwd()
	if err != nil {
		log.Printf("⚠️ FCM: cannot get working directory: %v", err)
		return &FcmService{}
	}
	keyPath := filepath.Join(
		wd,
		"internal", "config", "firebase",
		"delivery-app-dbe88-firebase-adminsdk-fbsvc-052daad07d.json",
	)
	opt := option.WithCredentialsFile(keyPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Printf("⚠️ FCM init error: %v", err)
		return &FcmService{}
	}
	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Printf("⚠️ FCM messaging client error: %v", err)
		return &FcmService{}
	}
	log.Println("✅ FCM initialized successfully")
	return &FcmService{client: client}
}

// globalFcm is the singleton FCM service instance.
var globalFcm = newFcmService()

// SendToToken sends a push notification to a single device.
func (f *FcmService) SendToToken(
	token, title, body string,
) error {
	if f.client == nil || token == "" {
		return nil
	}
	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "driver_order_channel",
				Sound:     "default",
			},
		},
	}
	_, err := f.client.Send(context.Background(), msg)
	if err != nil {
		log.Printf("⚠️ FCM send error: %v", err)
	}
	return err
}

// SendToMultiple sends a push to multiple device tokens.
func (f *FcmService) SendToMultiple(
	tokens []string, title, body string,
) {
	for _, token := range tokens {
		go f.SendToToken(token, title, body) //nolint:errcheck
	}
}

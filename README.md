# Delivery Mobile App

A full-stack delivery store application with a **Go backend** and **Flutter mobile** frontend.

## Tech Stack

| Layer    | Technology         |
|----------|--------------------|
| Backend  | Go (Golang)        |
| Mobile   | Flutter / Dart     |
| Database | PostgreSQL         |

## Project Structure

```
Delivery_MobileAPP/
├── backend/          # Go REST API server
│   ├── cmd/          # Application entry points
│   ├── internal/     # Private application code
│   └── go.mod        # Go module file
├── mobile/           # Flutter mobile app
│   ├── lib/          # Dart source code
│   │   ├── core/     # Theme, providers, network
│   │   └── features/ # Feature modules (home, settings)
│   ├── assets/       # Images and static assets
│   └── pubspec.yaml  # Flutter dependencies
└── README.md
```

## Getting Started

### Backend
```bash
cd backend
go mod download
go run cmd/server/main.go
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

## Features

- Product catalog with image gallery
- Dark / Light theme toggle
- Bilingual support (English / Vietnamese)
- Settings page (Theme + Language)

## License

MIT

Cách 1: Xóa app data trên thiết bị (Nhanh nhất)
# Trên Android device/emulator
adb shell pm clear com.delivery.delivery_app

Cách 2: Uninstall và reinstall
bash
flutter clean
flutter pub get
flutter run


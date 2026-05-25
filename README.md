# Delivery Mobile App

A full-stack delivery and e-commerce store application with a **Go backend** and **Flutter mobile** frontend.

## 🛠 Tech Stack

| Layer    | Technology     |
| -------- | -------------- |
| Backend  | Go (Golang)    |
| Mobile   | Flutter / Dart |
| Database | PostgreSQL     |

## 📁 Project Structure

```text
Delivery_MobileAPP/
├── backend/          # Go REST API server
│   ├── cmd/          # Application entry points
│   ├── internal/     # Private application code
│   └── go.mod        # Go module file
├── mobile/           # Flutter mobile app
│   ├── lib/          # Dart source code
│   │   ├── core/     # Theme, providers, network
│   │   └── features/ # Feature modules (auth, home, menu, seller, cart, orders)
│   ├── assets/       # Images and static assets
│   └── pubspec.yaml  # Flutter dependencies
```

## ✨ Features (Chức năng chính)

Hệ thống cung cấp trải nghiệm toàn diện cho nhiều đối tượng người dùng khác nhau thông qua cơ chế **Chuyển đổi vai trò (Role-Switching)** linh hoạt.

### 1. 🌐 Tính năng chung (Global)

- **Đăng nhập & Đăng ký**: Hỗ trợ qua Email/Password, Google, Facebook; ghi nhớ lựa chọn role lần đầu.
- **Đa ngôn ngữ & Theme**: Hỗ trợ Tiếng Anh/Tiếng Việt, giao diện sáng/tối với `IndieFolkTheme`.
- **Vector Intelligence**: Tìm kiếm thông minh bằng từ khóa ngữ nghĩa (Semantic Search) sử dụng Vector Embedding qua Gemini AI.

### 2. 🛒 Người mua hàng (Buyer)

- **Mua sắm & Thanh toán**: Quản lý giỏ hàng linh hoạt, đặt hàng nhanh chóng, quản lý danh sách địa chỉ nhận hàng.
- **Trò chuyện & Trợ lý ảo**: Chat trực tiếp với Shop (gửi ảnh, sticker); tích hợp trả lời tự động bằng RAG AI khi Shop offline.
- **Hệ thống thông báo**: Tích hợp thông báo đẩy qua Firebase Cloud Messaging (FCM) và trang danh sách thông báo tiện lợi.

### 3. 🏪 Người bán hàng (Seller)

- **Quản lý Cửa hàng & Sản phẩm**: Mở Shop mới, đăng bán sản phẩm (tự động xử lý nền ảnh), quản lý đơn hàng của Shop.
- **Báo cáo trực quan**: Dashboard thống kê doanh thu, đơn hàng chi tiết.

### 4. 🛵 Tài xế giao hàng (Driver)

- **Bản đồ & Định vị**: Cập nhật tọa độ GPS theo thời gian thực khi thay đổi địa điểm.
- **Bảng gom đơn**: Nhận các đơn hàng chờ vận chuyển dựa trên khoảng cách địa lý (Radius Filtering).
- **Trạng thái giao vận**: Cập nhật linh hoạt quá trình lấy hàng, đang giao, đã giao.

## 🚀 Getting Started

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

## 📝 Troubleshooting & Maintenance

**Cách 1: Xóa app data trên thiết bị (Nhanh nhất nếu gặp lỗi cache/state)**

```bash
# Trên Android device/emulator
adb shell pm clear com.delivery.delivery_app
```

**Cách 2: Uninstall và reinstall (Clean build)**

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## License

dodd-maindev

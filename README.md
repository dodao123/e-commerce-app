# Delivery Mobile App

A full-stack delivery and e-commerce store application with a **Go backend** and **Flutter mobile** frontend.

## 🛠 Tech Stack

| Layer    | Technology         |
|----------|--------------------|
| Backend  | Go (Golang)        |
| Mobile   | Flutter / Dart     |
| Database | PostgreSQL         |

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
- **Đăng nhập & Đăng ký**: Hỗ trợ xác thực qua Email/Password, Google, và Facebook.
- **Đa ngôn ngữ**: Hỗ trợ đầy đủ Tiếng Anh (English) và Tiếng Việt.
- **Giao diện sáng/tối (Dark Mode)**: Hệ thống Theme thông minh `IndieFolkTheme` tùy biến cao cho toàn bộ ứng dụng.
- **Duyệt sản phẩm**: Xem danh sách sản phẩm, chi tiết, và gợi ý sản phẩm ("Có thể bạn cũng thích").

### 2. 🛒 Người mua hàng (Buyer)
- **Quản lý giỏ hàng**: Thêm/Sửa/Xóa sản phẩm, tính toán giá trị giỏ hàng.
- **Thanh toán (Checkout)**: Đặt hàng, quản lý danh sách địa chỉ giao hàng.
- **Quản lý đơn hàng**: Theo dõi lịch sử và trạng thái đơn mua (Chờ xác nhận, Đang giao, Đã giao).
- **Trang cá nhân (Menu)**:
  - Bảng điều khiển (Dashboard) theo dõi nhanh tiến trình đơn hàng.
  - Quản lý tiện ích: Ví điện tử, Liên kết ngân hàng, Voucher giảm giá.
  - Trung tâm hỗ trợ (Help Center) & Trò chuyện trực tuyến (Chat).

### 3. 🏪 Người bán hàng (Seller)
- **Quản lý Cửa hàng**: Mở Shop mới, bảng điều khiển (Dashboard) thống kê tổng quan doanh thu, số lượng đơn.
- **Quản lý Sản phẩm**:
  - Đăng bán sản phẩm mới (chọn hình ảnh, giá cả, tình trạng, danh mục).
  - Chỉnh sửa hoặc ẩn/hiện sản phẩm đang bán.
- **Quản lý Đơn hàng (Seller Orders)**: Tiếp nhận đơn đặt hàng từ khách, cập nhật trạng thái đơn (Chờ lấy hàng, Đang giao, Đơn hủy, Đã giao).
- **Công cụ bán hàng**: Quảng cáo (Promote), Tiếp thị liên kết (Affiliate), Xem hiệu quả bán hàng.

### 4. 🛵 Tài xế giao hàng (Driver) *(Tính năng mở rộng)*
- Hệ thống đã tích hợp kiến trúc chuyển đổi quyền (Role) sang Tài xế. 
- *Đang trong quá trình hoàn thiện các UI/UX chuyên biệt cho quy trình nhận đơn và giao vận.*

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

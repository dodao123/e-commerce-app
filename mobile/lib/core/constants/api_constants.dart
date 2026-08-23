/// Centralized API configuration constants.
///
/// [baseUrl] is resolved from the `API_HOST` dart-define at build time.
/// Usage: `flutter run --dart-define=API_HOST=192.168.x.x`
/// Or use the `scripts/run_dev.ps1` script for automatic IP detection.
class ApiConstants {
  ApiConstants._();

  /// Backend server port.
  static const String _serverPort = '8081';

  /// Host injected via `--dart-define=API_HOST=<ip>`.
  /// Falls back to current Wi-Fi IP or emulator alias.
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.38.103',
  );

  /// Base URL for the backend API server (auto-resolved).
  static const String baseUrl = 'http://$_apiHost:$_serverPort';

  /// Base WebSocket URL for chat connections.
  static String websocketUrl(String token) {
    return 'ws://$_apiHost:$_serverPort/api/v1/chat/ws?token=$token';
  }

  /// Resolves an image URL, replacing any stale IP address with the current [baseUrl].
  static String resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.contains('/uploads/')) {
      final idx = url.indexOf('/uploads/');
      return '$baseUrl${url.substring(idx)}';
    }
    if (!url.startsWith('http')) {
      return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
    }
    return url;
  }

  /// Health check endpoint path.
  static const String healthEndpoint = '/api/v1/health';

  /// Google login endpoint.
  static const String googleLoginEndpoint = '/api/v1/auth/google';

  /// Facebook login endpoint.
  static const String facebookLoginEndpoint = '/api/v1/auth/facebook';

  /// Update user role endpoint.
  static const String updateRoleEndpoint = '/api/v1/auth/role';

  /// Email register endpoint.
  static const String registerEndpoint = '/api/v1/auth/register';

  /// Email login endpoint.
  static const String loginEndpoint = '/api/v1/auth/login';

  /// Create shop endpoint (POST).
  static const String createShopEndpoint = '/api/v1/shops';

  /// Get my shop endpoint (GET).
  static const String getMyShopEndpoint = '/api/v1/shops/me';

  /// Update shop endpoint prefix (PUT /api/v1/shops/{id}).
  static const String updateShopEndpoint = '/api/v1/shops';

  /// Create product endpoint (POST).
  static const String createProductEndpoint = '/api/v1/products';

  /// List my products endpoint (GET, auth required).
  static const String listProductsEndpoint = '/api/v1/products';

  /// Public products feed endpoint (GET, no auth).
  static const String publicProductsEndpoint = '/api/v1/products/public';

  /// Shop products endpoint (GET /api/v1/shops/{shopId}/products).
  static const String shopProductsEndpoint = '/api/v1/shops';

  /// Product detail endpoint prefix (GET /api/v1/products/{id}).
  static const String productDetailEndpoint = '/api/v1/products';

  /// Upload product images (POST /api/v1/products/{id}/images).
  static const String uploadImagesEndpoint = '/api/v1/products';

  /// Cart endpoint (GET /api/v1/cart — list items).
  static const String cartEndpoint = '/api/v1/cart';

  /// Cart items endpoint (POST add, PUT/DELETE by id).
  static const String cartItemsEndpoint = '/api/v1/cart/items';

  /// Cart count endpoint (GET /api/v1/cart/count).
  static const String cartCountEndpoint = '/api/v1/cart/count';

  /// Delivery addresses endpoint (CRUD).
  static const String addressesEndpoint = '/api/v1/addresses';

  /// Orders endpoint (POST create, GET list).
  static const String ordersEndpoint = '/api/v1/orders';

  /// Shop orders endpoint (GET seller orders).
  static const String shopOrdersEndpoint = '/api/v1/shop/orders';

  /// Shop orders count endpoint (GET pending count).
  static const String shopOrdersCountEndpoint = '/api/v1/shop/orders/count';

  /// Notifications endpoint (GET list).
  static const String notificationsEndpoint = '/api/v1/notifications';

  /// Unread notifications count endpoint.
  static const String notifUnreadEndpoint = '/api/v1/notifications/unread';

  /// FCM device token registration endpoint.
  static const String fcmTokenEndpoint = '/api/v1/fcm/token';

  /// Default request timeout in seconds.
  static const int timeoutSeconds = 10;

  /// Google Web Client ID (for serverClientId on mobile).
  static const String googleWebClientId =
      '978444193774-2p00rh9qapfuh96c9smuic7aiuh9krrq'
      '.apps.googleusercontent.com';
}

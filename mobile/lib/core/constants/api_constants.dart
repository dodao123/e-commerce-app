/// Centralized API configuration constants.
///
/// [baseUrl] is resolved from the `API_HOST` dart-define at build time.
/// Usage: `flutter run --dart-define=API_HOST=192.168.x.x`
/// Or use the `scripts/run_dev.ps1` script for automatic IP detection.
class ApiConstants {
  ApiConstants._();

  /// Backend server port.
  static const String _serverPort = '8080';

  /// Host injected via `--dart-define=API_HOST=<ip>`.
  /// Falls back to `10.0.2.2` (Android emulator alias for localhost).
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );

  /// Base URL for the backend API server (auto-resolved).
  static const String baseUrl = 'http://$_apiHost:$_serverPort';

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

  /// List my products endpoint (GET).
  static const String listProductsEndpoint = '/api/v1/products';

  /// Product detail endpoint prefix (GET /api/v1/products/{id}).
  static const String productDetailEndpoint = '/api/v1/products';

  /// Upload product images (POST /api/v1/products/{id}/images).
  static const String uploadImagesEndpoint = '/api/v1/products';

  /// Default request timeout in seconds.
  static const int timeoutSeconds = 10;

  /// Google Web Client ID (for serverClientId on mobile).
  static const String googleWebClientId =
      '978444193774-2p00rh9qapfuh96c9smuic7aiuh9krrq'
      '.apps.googleusercontent.com';
}

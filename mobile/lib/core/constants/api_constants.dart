/// Centralized API configuration constants.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API server.
  /// Uses PC's WiFi IP for physical device testing.
  static const String baseUrl = 'http://192.168.1.5:8080';

  /// Base URL for physical device (use your PC's local IP).
  static const String physicalDeviceUrl = 'http://192.168.1.100:8080';

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

  /// Default request timeout in seconds.
  static const int timeoutSeconds = 10;

  /// Google Web Client ID (for serverClientId on mobile).
  /// This is the Web client ID from Google Cloud Console.
  static const String googleWebClientId =
      '978444193774-2p00rh9qapfuh96c9smuic7aiuh9krrq.apps.googleusercontent.com';
}

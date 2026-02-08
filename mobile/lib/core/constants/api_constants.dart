/// Centralized API configuration constants.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API server.
  /// Uses localhost with ADB reverse port forwarding (adb reverse tcp:8080 tcp:8080).
  static const String baseUrl = 'http://localhost:8080';

  /// Base URL for physical device (use your PC's local IP).
  static const String physicalDeviceUrl = 'http://192.168.1.100:8080';

  /// Health check endpoint path.
  static const String healthEndpoint = '/api/v1/health';

  /// Default request timeout in seconds.
  static const int timeoutSeconds = 10;
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// HTTP client wrapper for communicating with the backend API.
class ApiClient {
  final http.Client _httpClient;
  final String _baseUrl;

  /// Creates an ApiClient with optional custom HTTP client and base URL.
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Performs a GET request to the specified endpoint.
  /// Returns decoded JSON response as a Map.
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient
        .get(uri)
        .timeout(
          const Duration(seconds: ApiConstants.timeoutSeconds),
        );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Request failed: ${response.reasonPhrase}',
    );
  }

  /// Releases HTTP client resources.
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  /// HTTP status code of the failed request.
  final int statusCode;

  /// Human-readable error message.
  final String message;

  /// Creates an ApiException with status code and message.
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

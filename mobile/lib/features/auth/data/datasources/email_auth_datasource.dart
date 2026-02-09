import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

/// Data source for email-based authentication API calls.
class EmailAuthDatasource {
  /// Registers a new user via email/password.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    debugPrint('🔵 [Auth] Registering: $email');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds),
    );

    return _handleResponse(response);
  }

  /// Logs in an existing user via email/password.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    debugPrint('🔵 [Auth] Logging in: $email');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Request failed');
    }

    debugPrint('🟢 [Auth] Success');
    return body;
  }
}

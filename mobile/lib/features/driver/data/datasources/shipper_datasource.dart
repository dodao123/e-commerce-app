import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';

/// DataSource for shipper profile operations.
class ShipperDataSource {
  final _client = http.Client();
  final _token = TokenManager();

  /// Fetches the logged-in driver's profile.
  /// Returns null if not registered yet.
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await _token.getToken();
    if (token == null) throw Exception('No token');

    try {
      final res = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/shippers/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else if (res.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get profile: ${res.statusCode}');
    } catch (e) {
      debugPrint('Error getting shipper profile: $e');
      rethrow;
    }
  }

  /// Creates or updates the driver's profile.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await _token.getToken();
    if (token == null) throw Exception('No token');

    try {
      final res = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/shippers/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception('Failed to update profile: ${res.body}');
    } catch (e) {
      debugPrint('Error updating shipper profile: $e');
      rethrow;
    }
  }
}

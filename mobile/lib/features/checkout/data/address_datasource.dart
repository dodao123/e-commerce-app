import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';

/// Remote data source for delivery address operations.
class AddressDatasource {
  final http.Client _client = http.Client();
  final TokenManager _token = TokenManager();

  Future<Map<String, String>> _headers() async {
    final t = await _token.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }

  /// Fetches all addresses for current user.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.addressesEndpoint}');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Address fetch error: $e');
      return [];
    }
  }

  /// Creates a new address.
  Future<Map<String, dynamic>?> create(
      Map<String, dynamic> addr) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.addressesEndpoint}');
      final r = await _client.post(url,
          headers: await _headers(),
          body: jsonEncode(addr));
      if (r.statusCode == 201) {
        return jsonDecode(r.body);
      }
      return null;
    } catch (e) {
      debugPrint('Address create error: $e');
      return null;
    }
  }
}

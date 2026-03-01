import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';

/// Remote data source for order operations.
class OrderDatasource {
  final http.Client _client = http.Client();
  final TokenManager _token = TokenManager();

  Future<Map<String, String>> _headers() async {
    final t = await _token.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }

  /// Places a new order.
  Future<Map<String, dynamic>?> placeOrder(
      Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.ordersEndpoint}');
      final r = await _client.post(url,
          headers: await _headers(),
          body: jsonEncode(body));
      if (r.statusCode == 201) {
        return jsonDecode(r.body);
      }
      debugPrint('Place order err: ${r.body}');
      return null;
    } catch (e) {
      debugPrint('Place order error: $e');
      return null;
    }
  }

  /// Fetches buyer's orders.
  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.ordersEndpoint}');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Fetch orders error: $e');
      return [];
    }
  }

  /// Fetches order detail by ID.
  Future<Map<String, dynamic>?> fetchDetail(
      String id) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.ordersEndpoint}/$id');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode == 200) {
        return jsonDecode(r.body);
      }
      return null;
    } catch (e) {
      debugPrint('Order detail error: $e');
      return null;
    }
  }

  /// Cancels an order (only if pending).
  Future<bool> cancelOrder(String orderId) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.ordersEndpoint}'
          '/$orderId/status');
      final r = await _client.put(url,
          headers: await _headers(),
          body: jsonEncode({'status': 'cancelled'}));
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('Cancel order error: $e');
      return false;
    }
  }
}

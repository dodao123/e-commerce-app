import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';

/// Remote data source for seller order management.
class ShopOrderDatasource {
  final http.Client _client = http.Client();
  final TokenManager _token = TokenManager();

  Future<Map<String, String>> _headers() async {
    final t = await _token.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }

  /// Fetches orders for a seller's shop.
  Future<List<Map<String, dynamic>>> fetchShopOrders(
      String shopId) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.shopOrdersEndpoint}'
          '?shop_id=$shopId');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Shop orders error: $e');
      return [];
    }
  }

  /// Fetches pending order count for a shop.
  Future<int> fetchPendingCount(String shopId) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.shopOrdersCountEndpoint}'
          '?shop_id=$shopId');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return 0;
      final data = jsonDecode(r.body);
      return data['count'] ?? 0;
    } catch (e) {
      debugPrint('Pending count error: $e');
      return 0;
    }
  }

  /// Updates order status.
  Future<bool> updateStatus(
      String orderId, String status) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.ordersEndpoint}'
          '/$orderId/status');
      final r = await _client.put(url,
          headers: await _headers(),
          body: jsonEncode({'status': status}));
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('Update status error: $e');
      return false;
    }
  }
}

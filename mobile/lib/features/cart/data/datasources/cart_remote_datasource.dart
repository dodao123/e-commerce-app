import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';
import '../models/cart_item_model.dart';

/// Remote data source for shopping cart API calls.
/// All endpoints require JWT authentication.
class CartRemoteDatasource {
  final http.Client _client = http.Client();
  final TokenManager _tokenManager = TokenManager();

  /// Returns the auth headers with JWT Bearer token.
  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetches all cart items for the current buyer.
  Future<List<CartItemModel>> fetchCart() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.cartEndpoint}');
    final response = await _client.get(
        url, headers: await _authHeaders());

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => CartItemModel.fromJson(json))
        .toList();
  }

  /// Adds a product to cart. Returns true if successful.
  Future<bool> addItem(String productId, int quantity) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.cartItemsEndpoint}');
      final response = await _client.post(url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'product_id': productId,
            'quantity': quantity,
          }));

      debugPrint('🛒 Add to cart: ${response.statusCode}'
          ' — ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('🛒 Add to cart error: $e');
      return false;
    }
  }

  /// Updates the quantity of a cart item.
  Future<bool> updateQuantity(String itemId, int qty) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.cartItemsEndpoint}/$itemId');
    final response = await _client.put(url,
        headers: await _authHeaders(),
        body: jsonEncode({'quantity': qty}));

    return response.statusCode == 200;
  }

  /// Removes a cart item by ID.
  Future<bool> removeItem(String itemId) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.cartItemsEndpoint}/$itemId');
    final response = await _client.delete(
        url, headers: await _authHeaders());

    return response.statusCode == 200;
  }

  /// Fetches the total cart item count for badge display.
  Future<int> fetchCount() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.cartCountEndpoint}');
      final response = await _client.get(
          url, headers: await _authHeaders());

      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } catch (e) {
      debugPrint('Cart count error: $e');
      return 0;
    }
  }
}

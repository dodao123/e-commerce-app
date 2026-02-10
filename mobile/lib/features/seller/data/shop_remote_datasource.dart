import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

/// Remote datasource for shop CRUD operations.
/// Communicates with the Go backend shop API.
class ShopRemoteDatasource {
  final http.Client _client;

  /// Creates a ShopRemoteDatasource with optional HTTP client.
  ShopRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Creates a new shop for the authenticated seller.
  Future<Map<String, dynamic>> createShop({
    required String token,
    required Map<String, dynamic> shopData,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createShopEndpoint}');
    final response = await _client.post(url,
      headers: _authHeaders(token),
      body: jsonEncode(shopData),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    return _handleResponse(response);
  }

  /// Retrieves the current seller's shop.
  Future<Map<String, dynamic>?> getMyShop({
    required String token,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getMyShopEndpoint}');
    final response = await _client.get(url,
      headers: _authHeaders(token),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode == 404) return null;
    return _handleResponse(response);
  }

  /// Updates an existing shop by ID.
  Future<Map<String, dynamic>> updateShop({
    required String token,
    required String shopId,
    required Map<String, dynamic> shopData,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}'
      '${ApiConstants.updateShopEndpoint}/$shopId');
    final response = await _client.put(url,
      headers: _authHeaders(token),
      body: jsonEncode(shopData),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    return _handleResponse(response);
  }

  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['error'] ?? 'Unknown error');
  }
}

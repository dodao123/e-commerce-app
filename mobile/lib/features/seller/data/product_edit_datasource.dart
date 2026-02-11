import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

/// Remote datasource for product update and delete operations.
/// Handles PUT, DELETE, and image management API calls.
class ProductEditDatasource {
  final http.Client _client;

  /// Creates a ProductEditDatasource with optional client.
  ProductEditDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Retrieves a single product by its ID.
  Future<Map<String, dynamic>> getProduct({
    required String token,
    required String productId,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.productDetailEndpoint}/$productId');
    final response = await _client.get(url,
      headers: _authHeaders(token),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    return _handleResponse(response);
  }

  /// Updates product fields via PUT request.
  Future<Map<String, dynamic>> updateProduct({
    required String token,
    required String productId,
    required Map<String, dynamic> updateData,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.productDetailEndpoint}/$productId');
    final response = await _client.put(url,
      headers: _authHeaders(token),
      body: jsonEncode(updateData),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    return _handleResponse(response);
  }

  /// Deletes a product by its ID.
  Future<void> deleteProduct({
    required String token,
    required String productId,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.productDetailEndpoint}/$productId');
    final response = await _client.delete(url,
      headers: _authHeaders(token),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Delete failed');
    }
  }

  /// Deletes specific images from a product.
  Future<List<String>> deleteImages({
    required String token,
    required String productId,
    required List<String> imagePaths,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.productDetailEndpoint}'
        '/$productId/images/delete');
    final response = await _client.post(url,
      headers: _authHeaders(token),
      body: jsonEncode({'images': imagePaths}),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    final body = _handleResponse(response);
    final remaining = body['remaining'] as List? ?? [];
    return remaining.cast<String>();
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

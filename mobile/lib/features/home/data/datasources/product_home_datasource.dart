import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

/// Fetches public products from backend for the home page feed.
/// Uses the public endpoint (no auth required).
class ProductHomeDatasource {
  final http.Client _client = http.Client();

  /// Fetches public products with pagination support.
  /// [limit] controls how many products per page.
  /// [offset] controls where to start fetching.
  Future<List<ProductModel>> fetchProducts({
    int limit = 10,
    int offset = 0,
    String category = '',
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.publicProductsEndpoint}'
        '?limit=$limit&offset=$offset'
        '${category.isNotEmpty ? "&category=$category" : ""}');

    final response = await _client.get(url, headers: {
      'Content-Type': 'application/json',
    }).timeout(
        const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => ProductModel.fromApiJson(json))
        .toList();
  }

  /// Fetches public products of a specific shop.
  Future<List<ProductModel>> fetchShopProducts(String shopId, {int limit = 100}) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.shopProductsEndpoint}/$shopId/products'
        '?limit=$limit');

    final response = await _client.get(url, headers: {
      'Content-Type': 'application/json',
    }).timeout(
        const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => ProductModel.fromApiJson(json))
        .toList();
  }
}

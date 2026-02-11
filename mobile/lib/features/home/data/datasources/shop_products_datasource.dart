import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

/// Fetches products from a specific shop (public endpoint).
class ShopProductsDatasource {
  final http.Client _client = http.Client();

  /// Fetches other products from the same shop.
  /// [shopId] is the shop identifier.
  /// [excludeId] excludes the current product from results.
  /// [limit] controls how many products to load.
  Future<List<ProductModel>> fetchShopProducts({
    required String shopId,
    String excludeId = '',
    int limit = 10,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.shopProductsEndpoint}'
        '/$shopId/products'
        '?exclude=$excludeId&limit=$limit');

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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';
import '../models/product_model.dart';

/// Fetches products from the backend API for the home page.
class ProductHomeDatasource {
  final http.Client _client = http.Client();

  /// Fetches all active products from the API.
  /// Returns a list of ProductModel mapped from API response.
  Future<List<ProductModel>> fetchProducts() async {
    final token = await TokenManager().getToken();
    if (token == null) return [];

    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.listProductsEndpoint}');

    final response = await _client.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(
        const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => ProductModel.fromApiJson(json))
        .toList();
  }
}

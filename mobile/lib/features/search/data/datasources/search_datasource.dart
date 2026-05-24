import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../home/data/models/product_model.dart';

/// Response model for the hybrid search endpoint.
class SearchResponse {
  /// Merged product list: keyword matches first, semantic after.
  final List<ProductModel> products;

  /// How many products matched by exact keyword.
  final int exactCount;

  /// Total count of all returned products.
  final int count;

  /// Creates a SearchResponse.
  const SearchResponse({
    required this.products,
    required this.exactCount,
    required this.count,
  });
}

/// Datasource that calls the hybrid search API endpoint.
class SearchDatasource {
  final http.Client _client = http.Client();

  /// Performs a hybrid search query against the backend.
  Future<SearchResponse> search({
    required String query,
    int limit = 20,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/search'
        '?q=${Uri.encodeComponent(query)}&limit=$limit');

    final response = await _client.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Search failed: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final rawList = body['products'] as List<dynamic>? ?? [];
    final products = rawList
        .map((j) => ProductModel.fromApiJson(j as Map<String, dynamic>))
        .toList();

    return SearchResponse(
      products: products,
      exactCount: body['exact_count'] as int? ?? 0,
      count: body['count'] as int? ?? products.length,
    );
  }
}

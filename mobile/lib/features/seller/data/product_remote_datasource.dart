import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/api_constants.dart';

/// Remote datasource for product CRUD operations.
/// Communicates with the Go backend product API.
class ProductRemoteDatasource {
  final http.Client _client;

  /// Creates a ProductRemoteDatasource with optional client.
  ProductRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Creates a new product for the seller's shop.
  Future<Map<String, dynamic>> createProduct({
    required String token,
    required Map<String, dynamic> productData,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.createProductEndpoint}');
    final response = await _client.post(url,
      headers: _authHeaders(token),
      body: jsonEncode(productData),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    return _handleResponse(response);
  }

  /// Uploads images to server for a specific product.
  /// Returns list of server-side image paths.
  Future<List<String>> uploadImages({
    required String token,
    required String productId,
    required List<String> localPaths,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}'
        '${ApiConstants.uploadImagesEndpoint}'
        '/$productId/images');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    for (final path in localPaths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final ext = path.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      request.files.add(await http.MultipartFile.fromPath(
        'images', path, contentType: mime));
    }

    final streamed = await request.send().timeout(
        const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body)
        as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final uploaded = body['uploaded'] as List? ?? [];
      return uploaded.cast<String>();
    }
    throw Exception(body['error'] ?? 'Upload failed');
  }

  /// Retrieves products for the seller's shop.
  Future<List<dynamic>> listProducts({
    required String token,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var path = '${ApiConstants.listProductsEndpoint}'
        '?limit=$limit&offset=$offset';
    if (status != null && status.isNotEmpty) {
      path += '&status=$status';
    }

    final url = Uri.parse(
        '${ApiConstants.baseUrl}$path');
    final response = await _client.get(url,
      headers: _authHeaders(token),
    ).timeout(
      const Duration(seconds: ApiConstants.timeoutSeconds));

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body is List ? body : [];
    }
    throw Exception(body['error'] ?? 'Unknown error');
  }

  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleResponse(
      http.Response response) {
    final body = jsonDecode(response.body)
        as Map<String, dynamic>;
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }
    throw Exception(body['error'] ?? 'Unknown error');
  }
}

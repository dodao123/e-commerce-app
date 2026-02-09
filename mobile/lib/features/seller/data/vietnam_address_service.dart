import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to fetch Vietnam provinces, districts, wards.
/// Uses the open-api.vn provinces API.
class VietnamAddressService {
  VietnamAddressService._();

  static const _baseUrl = 'https://provinces.open-api.vn/api';

  /// Fetches all 63 provinces/cities.
  static Future<List<Map<String, dynamic>>> fetchProvinces() async {
    final res = await http.get(Uri.parse('$_baseUrl/?depth=1'));
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    return [];
  }

  /// Fetches districts for a given province code.
  static Future<List<Map<String, dynamic>>> fetchDistricts(
      int provinceCode) async {
    final res = await http.get(
        Uri.parse('$_baseUrl/p/$provinceCode?depth=2'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
          data['districts'] ?? []);
    }
    return [];
  }

  /// Fetches wards for a given district code.
  static Future<List<Map<String, dynamic>>> fetchWards(
      int districtCode) async {
    final res = await http.get(
        Uri.parse('$_baseUrl/d/$districtCode?depth=2'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
          data['wards'] ?? []);
    }
    return [];
  }
}

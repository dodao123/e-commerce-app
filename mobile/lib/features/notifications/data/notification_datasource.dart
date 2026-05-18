import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_manager.dart';

/// Remote data source for notification operations.
class NotificationDatasource {
  final http.Client _client = http.Client();
  final TokenManager _token = TokenManager();

  Future<Map<String, String>> _headers() async {
    final t = await _token.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }

  /// Fetches all notifications for logged-in user.
  Future<List<Map<String, dynamic>>> fetchAll(String role) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.notificationsEndpoint}?role=$role');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
      return [];
    }
  }

  /// Returns unread notification count.
  Future<int> fetchUnreadCount(String role) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.notifUnreadEndpoint}?role=$role');
      final r = await _client.get(
          url, headers: await _headers());
      if (r.statusCode != 200) return 0;
      final data = jsonDecode(r.body);
      return data['count'] ?? 0;
    } catch (e) {
      debugPrint('Unread count error: $e');
      return 0;
    }
  }

  /// Marks a notification as read.
  Future<bool> markRead(String notifId) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.notificationsEndpoint}'
          '/$notifId/read');
      final r = await _client.put(
          url, headers: await _headers());
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('Mark read error: $e');
      return false;
    }
  }
}

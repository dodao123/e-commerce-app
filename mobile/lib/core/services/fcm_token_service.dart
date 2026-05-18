import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/token_manager.dart';
import 'notification_polling_service.dart';

/// Registers the device FCM token to the backend after login.
/// This allows the backend to send targeted push notifications.
class FcmTokenService {
  final http.Client _client = http.Client();
  final TokenManager _tokenManager = TokenManager();

  /// Fetches FCM token from Firebase and sends it to the backend.
  Future<void> registerToken() async {
    try {
      final fcmToken = await NotificationPollingService().getFcmToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('⚠️ FCM token not available yet');
        return;
      }
      final jwt = await _tokenManager.getToken();
      if (jwt == null || jwt.isEmpty) return;

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.fcmTokenEndpoint}',
      );
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': fcmToken}),
      );
      if (response.statusCode == 200) {
        debugPrint('✅ FCM token registered to backend');
      } else {
        debugPrint('⚠️ FCM token registration failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ FCM token registration error: $e');
    }
  }
}

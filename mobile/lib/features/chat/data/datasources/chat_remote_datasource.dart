import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDatasource {
  final http.Client _client;

  ChatRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<ChatRoomModel> getOrCreateRoom({
    required String token,
    required String roomType,
    String? shopId,
    String? shipperId,
    String? associatedOrderId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/chat/rooms');
    final response = await _client.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        'room_type': roomType,
        if (shopId != null) 'shop_id': shopId,
        if (shipperId != null) 'shipper_id': shipperId,
        if (associatedOrderId != null) 'associated_order_id': associatedOrderId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get/create chat room: ${response.body}');
    }
    return ChatRoomModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ChatRoomModel>> listRooms({required String token}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/chat/rooms');
    final response = await _client.get(url, headers: _headers(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to list chat rooms: ${response.body}');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<ChatMessageModel>> listMessages({
    required String token,
    required String roomId,
    int limit = 50,
    int offset = 0,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/messages?limit=$limit&offset=$offset');
    final response = await _client.get(url, headers: _headers(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to list messages: ${response.body}');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead({required String token, required String roomId}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/read');
    final response = await _client.post(url, headers: _headers(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to mark read: ${response.body}');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/chat_message_model.dart';

class ChatWebSocketManager {
  WebSocket? _socket;
  final _messageController = StreamController<ChatMessageModel>.broadcast();

  Stream<ChatMessageModel> get messages => _messageController.stream;

  Future<void> connect(String token) async {
    await disconnect();
    try {
      final url = ApiConstants.websocketUrl(token);
      print('[WS] Connecting to: $url');
      _socket = await WebSocket.connect(url).timeout(const Duration(seconds: 5));
      print('[WS] Connected successfully. Ready state: ${_socket?.readyState}');
      _socket!.listen(
        (data) {
          print('[WS] Received data: $data');
          if (data is String) {
            try {
              final Map<String, dynamic> json = jsonDecode(data) as Map<String, dynamic>;
              final msg = ChatMessageModel.fromJson(json);
              _messageController.add(msg);
            } catch (e) {
              print('[WS] Error decoding message JSON: $e');
            }
          }
        },
        onError: (err) {
          print('[WS] Connection stream error: $err');
        },
        onDone: () {
          print('[WS] Connection closed by server');
        },
      );
    } catch (e) {
      print('[WS] Connection failed error: $e');
      rethrow;
    }
  }

  void sendMessage(String roomId, String content, {String messageType = 'text'}) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      final payload = jsonEncode({
        'room_id': roomId,
        'message_type': messageType,
        'content': content,
      });
      print('[WS] Sending message payload: $payload');
      _socket!.add(payload);
    } else {
      print('[WS] Cannot send message. Socket state: ${_socket == null ? "null" : "state " + _socket!.readyState.toString()}');
    }
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
    }
  }

  void dispose() {
    _messageController.close();
  }
}

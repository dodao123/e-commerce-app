import 'dart:async';
import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../helpers/chat_product_inquiry_helper.dart';
import 'chat_websocket_manager.dart';

/// Controller managing chat conversation state and real-time events.
class ChatDetailController extends ChangeNotifier {
  final ChatRemoteDatasource _datasource = ChatRemoteDatasource();
  final ChatWebSocketManager _wsManager = ChatWebSocketManager();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final List<ChatMessageModel> messages = [];

  StreamSubscription<ChatMessageModel>? _messageSubscription;
  bool loading = true, isAiTyping = false, showStickers = false;
  Timer? _typingTimer;

  /// Initializes chat history and WebSocket stream.
  Future<void> initChat({
    required String token,
    required String roomId,
    required String myId,
    ProductModel? initialProduct,
  }) async {
    try {
      final list = await _datasource.listMessages(token: token, roomId: roomId);
      messages.addAll(list);
      loading = false;
      notifyListeners();
      await _datasource.markAsRead(token: token, roomId: roomId);
    } catch (_) {
      loading = false;
      notifyListeners();
    }

    try {
      await _wsManager.connect(token);
      if (initialProduct != null) {
        ChatProductInquiryHelper.sendInquiry(
          wsManager: _wsManager,
          roomId: roomId,
          product: initialProduct,
        );
        startAiTyping();
      }
    } catch (_) {}

    _messageSubscription = _wsManager.messages.listen((msg) {
      if (msg.roomId == roomId && !messages.any((m) => m.id == msg.id)) {
        messages.insert(0, msg);
        if (msg.senderId != myId) {
          isAiTyping = false;
          _typingTimer?.cancel();
        }
        notifyListeners();
        _datasource.markAsRead(token: token, roomId: roomId);
      }
    });
  }

  /// Sends a text message.
  void sendTextMessage(String roomId) {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      _wsManager.sendMessage(roomId, text);
      textController.clear();
      startAiTyping();
    }
  }

  /// Sends a sticker message.
  void sendSticker(String roomId, String url) {
    _wsManager.sendMessage(roomId, url, messageType: 'sticker');
    startAiTyping();
  }

  /// Activates AI typing animation.
  void startAiTyping() {
    isAiTyping = true;
    notifyListeners();
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 15), () {
      isAiTyping = false;
      notifyListeners();
    });
  }

  /// Toggles sticker panel visibility.
  void toggleStickers() {
    if (showStickers) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
      showStickers = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingTimer?.cancel();
    _wsManager.disconnect();
    _wsManager.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../manager/chat_websocket_manager.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_messages_list.dart';
import '../widgets/sticker_panel.dart';

/// ChatDetailPage is the main chat conversation screen.
class ChatDetailPage extends StatefulWidget {
  final String roomId, partnerName, partnerAvatar;
  const ChatDetailPage({
    super.key, required this.roomId, required this.partnerName, required this.partnerAvatar,
  });
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatRemoteDatasource _datasource = ChatRemoteDatasource();
  final ChatWebSocketManager _wsManager = ChatWebSocketManager();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessageModel> _messages = [];
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  bool _loading = true, _isAiTyping = false, _showStickers = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState(); _initChat();
    _focusNode.addListener(() { if (_focusNode.hasFocus) setState(() => _showStickers = false); });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel(); _typingTimer?.cancel();
    _wsManager.disconnect(); _wsManager.dispose();
    _controller.dispose(); _focusNode.dispose(); super.dispose();
  }

  Future<void> _initChat() async {
    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    if (token == null) return;
    try {
      final list = await _datasource.listMessages(token: token, roomId: widget.roomId);
      setState(() { _messages.addAll(list); _loading = false; });
      await _datasource.markAsRead(token: token, roomId: widget.roomId);
    } catch (_) { setState(() { _loading = false; }); }
    try { await _wsManager.connect(token); } catch (_) {}
    _messageSubscription = _wsManager.messages.listen((msg) {
      if (msg.roomId == widget.roomId && !_messages.any((m) => m.id == msg.id)) {
        setState(() {
          _messages.insert(0, msg);
          if (msg.senderId != auth.userId) { _isAiTyping = false; _typingTimer?.cancel(); }
        });
        _datasource.markAsRead(token: token, roomId: widget.roomId);
      }
    });
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isNotEmpty) { _wsManager.sendMessage(widget.roomId, t); _controller.clear(); _startAiTyping(); }
  }

  void _sendSticker(String url) {
    _wsManager.sendMessage(widget.roomId, url, messageType: 'sticker'); _startAiTyping();
  }

  void _startAiTyping() {
    setState(() { _isAiTyping = true; });
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() { _isAiTyping = false; });
    });
  }

  void _toggleStickers() {
    if (_showStickers) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showStickers = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: IndieFolkTheme.surface(isDark),
      appBar: ChatAppBar(partnerName: widget.partnerName, partnerAvatar: widget.partnerAvatar),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(child: ChatMessagesList(
            messages: _messages, isAiTyping: _isAiTyping, myId: context.read<AuthProvider>().userId,
          )),
          ChatInputBar(
            controller: _controller, focusNode: _focusNode, onSend: _send,
            showStickerPanel: _showStickers, onToggleStickers: _toggleStickers,
          ),
          if (_showStickers) StickerPanel(onSendSticker: _sendSticker),
        ],
      ),
    );
  }
}

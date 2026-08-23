import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_input_bar.dart';
import 'chat_messages_list.dart';
import 'sticker_panel.dart';

/// Main body for ChatDetailPage displaying message list and input controls.
class ChatDetailBody extends StatelessWidget {
  final bool loading;
  final List<ChatMessageModel> messages;
  final bool isAiTyping;
  final String myId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool showStickers;
  final VoidCallback onToggleStickers;
  final ValueChanged<String> onSendSticker;

  const ChatDetailBody({
    super.key,
    required this.loading,
    required this.messages,
    required this.isAiTyping,
    required this.myId,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.showStickers,
    required this.onToggleStickers,
    required this.onSendSticker,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ChatMessagesList(
            messages: messages,
            isAiTyping: isAiTyping,
            myId: myId,
          ),
        ),
        ChatInputBar(
          controller: controller,
          focusNode: focusNode,
          onSend: onSend,
          showStickerPanel: showStickers,
          onToggleStickers: onToggleStickers,
        ),
        if (showStickers) StickerPanel(onSendSticker: onSendSticker),
      ],
    );
  }
}

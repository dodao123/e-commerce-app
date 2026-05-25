import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import 'message_bubble.dart';
import 'bouncing_dots_indicator.dart';

/// ChatMessagesList renders the conversation messages in a scrollable list.
class ChatMessagesList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final bool isAiTyping;
  final String? myId;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.isAiTyping,
    required this.myId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length + (isAiTyping ? 1 : 0),
      itemBuilder: (_, idx) {
        if (isAiTyping && idx == 0) {
          return const BouncingDotsIndicator();
        }
        final msg = messages[isAiTyping ? idx - 1 : idx];
        return MessageBubble(message: msg, isMe: msg.senderId == myId);
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAi = message.senderRole == 'ai_assistant';
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;
    final isImage = message.messageType == 'image';
    final isSticker = message.messageType == 'sticker';

    if (isSticker) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Image.network(
            ApiConstants.resolveImageUrl(message.content),
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.insert_emoticon,
              size: 60,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isMe
                ? IndieFolkTheme.tertiary(isDark)
                : isAi
                    ? const Color(0xFFD6975A).withOpacity(0.2)
                    : IndieFolkTheme.neutral(isDark).withOpacity(0.15),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
            border: isAi ? Border.all(color: IndieFolkTheme.tertiary(isDark), width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMe && isAi)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 12, color: IndieFolkTheme.tertiary(isDark)),
                      const SizedBox(width: 4),
                      Text(
                        'AI Assistant',
                        style: IndieFolkTheme.label(isDark).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: IndieFolkTheme.tertiary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ApiConstants.resolveImageUrl(message.content),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 60,
                    ),
                  ),
                )
              else
                Text(
                  message.content,
                  style: IndieFolkTheme.body(isDark).copyWith(
                    fontSize: 15,
                    height: 1.3,
                    color: isMe ? Colors.white : IndieFolkTheme.primary(isDark),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

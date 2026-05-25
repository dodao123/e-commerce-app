import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// ChatInputBar provides the bottom text field and send button in the chat.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool showStickerPanel;
  final VoidCallback onToggleStickers;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.showStickerPanel,
    required this.onToggleStickers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: IndieFolkTheme.surface(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                showStickerPanel ? Icons.keyboard : Icons.insert_emoticon,
                color: IndieFolkTheme.tertiary(isDark),
              ),
              onPressed: onToggleStickers,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: IndieFolkTheme.body(isDark).copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: IndieFolkTheme.body(isDark).copyWith(
                    fontSize: 15,
                    color: IndieFolkTheme.secondary(isDark),
                  ),
                  fillColor: IndieFolkTheme.neutral(isDark).withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: IndieFolkTheme.tertiary(isDark)),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// StickerPanel displays a grid of 16 transparent PNG stickers served locally from the backend.
class StickerPanel extends StatelessWidget {
  final Function(String) onSendSticker;

  const StickerPanel({
    super.key,
    required this.onSendSticker,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 220,
      color: IndieFolkTheme.surface(isDark),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          final relativeUrl = '/uploads/stickers/sticker_${index + 1}.png';
          final fullUrl = ApiConstants.resolveImageUrl(relativeUrl);
          return GestureDetector(
            onTap: () => onSendSticker(relativeUrl),
            child: Image.network(
              fullUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.emoji_emotions_outlined, size: 32),
            ),
          );
        },
      ),
    );
  }
}

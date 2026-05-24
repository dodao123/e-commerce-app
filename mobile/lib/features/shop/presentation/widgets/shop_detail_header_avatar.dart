import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the Shop Details page banner and the overlapping circular shop avatar.
class ShopDetailHeaderAvatar extends StatelessWidget {
  final String shopId;
  final String avatarUrl;
  final bool isDark;

  const ShopDetailHeaderAvatar({
    super.key,
    required this.shopId,
    required this.avatarUrl,
    required this.isDark,
  });

  int _getBgIndex(String uuid) {
    if (uuid.isEmpty) return 1;
    int sum = 0;
    for (int i = 0; i < uuid.length; i++) {
      sum += uuid.codeUnitAt(i);
    }
    return (sum % 21) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ApiConstants.resolveImageUrl(avatarUrl);
    final hasBg = shopId.isNotEmpty;
    final bgIndex = _getBgIndex(shopId);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasBg ? null : LinearGradient(
                colors: isDark
                    ? [Colors.blueGrey.shade900, Colors.grey.shade900]
                    : [Colors.blueGrey.shade100, Colors.blueGrey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: hasBg ? DecorationImage(
                image: NetworkImage(
                  '${ApiConstants.baseUrl}/uploads/backgrounds/bg_$bgIndex.jpg',
                ),
                fit: BoxFit.cover,
              ) : null,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? const Icon(Icons.store, size: 36, color: AppColors.primary) : null,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// ChatAppBar provides the app bar with partner info and avatar.
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String partnerName;
  final String partnerAvatar;

  const ChatAppBar({
    super.key,
    required this.partnerName,
    required this.partnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: (partnerAvatar.isNotEmpty &&
                    !partnerAvatar.toLowerCase().endsWith('.svg'))
                ? NetworkImage(ApiConstants.resolveImageUrl(partnerAvatar))
                : null,
            child: (partnerAvatar.isEmpty ||
                    partnerAvatar.toLowerCase().endsWith('.svg'))
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            partnerName,
            style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 18),
          ),
        ],
      ),
      backgroundColor: IndieFolkTheme.surface(isDark),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Support section with help center, chat, and about links.
class MenuSupport extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates a MenuSupport widget.
  const MenuSupport({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(isVi ? 'Hỗ trợ' : 'Support',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          _supportTile(Icons.help_outline_rounded,
              isVi ? 'Trung tâm trợ giúp' : 'Help Center', isDark),
          _supportTile(Icons.headset_mic_outlined,
              isVi ? 'Trò chuyện với chúng tôi' : 'Chat with us', isDark),
          _supportTile(Icons.article_outlined,
              isVi ? 'Blog' : 'Blog', isDark),
        ]),
    );
  }

  Widget _supportTile(IconData icon, String label, bool isDark) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 22,
          color: isDark ? DarkColors.textPrimary : AppColors.textPrimary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Icon(Icons.chevron_right, size: 20,
          color: isDark ? DarkColors.textSecondary : AppColors.textSecondary),
      onTap: () {},
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A single role upgrade tile with icon, gradient, and arrow.
/// Used inside [MenuRoleUpgrade] to offer role switching.
class RoleUpgradeTile extends StatelessWidget {
  /// The icon to display on the left side.
  final IconData icon;

  /// The main title text.
  final String title;

  /// The subtitle description text.
  final String subtitle;

  /// The gradient colors for the icon container.
  final List<Color> gradientColors;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Creates a RoleUpgradeTile widget.
  const RoleUpgradeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _iconBox(),
          const SizedBox(width: 14),
          _textColumn(isDark),
          Icon(Icons.arrow_forward_ios_rounded, size: 14,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _iconBox() {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _textColumn(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textPrimary
                  : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12,
              color: isDark ? DarkColors.textSecondary
                  : AppColors.textSecondary)),
        ]),
    );
  }
}

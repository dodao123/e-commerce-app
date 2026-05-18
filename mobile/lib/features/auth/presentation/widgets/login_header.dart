import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Gradient header with logo and title for auth pages.
class LoginHeader extends StatelessWidget {
  /// Title text to display.
  final String title;

  /// Subtitle text to display.
  final String subtitle;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates a LoginHeader.
  const LoginHeader({super.key, required this.title, required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final headerBg = isDark ? IndieFolkTheme.surface(isDark) : IndieFolkTheme.tertiary(isDark);
    final headerText = isDark ? IndieFolkTheme.primary(isDark) : IndieFolkTheme.onPrimary(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo icon
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: headerText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: headerText,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(title,
              style: IndieFolkTheme.h1(isDark).copyWith(
                  color: headerText, fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: IndieFolkTheme.body(isDark).copyWith(
                  color: headerText.withValues(alpha: 0.8), fontSize: 14)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Reusable back button with glass morphism effect.
/// Used in Login and Register pages over the header gradient.
class AuthBackButton extends StatelessWidget {
  /// Whether dark mode is active.
  final bool isDark;

  /// Creates AuthBackButton widget.
  const AuthBackButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? IndieFolkTheme.primary(isDark) : IndieFolkTheme.onPrimary(isDark);

    return Positioned(top: 64, left: 14,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: iconColor.withValues(alpha: 0.2))),
          child: Icon(Icons.arrow_back_ios_rounded,
              color: iconColor, size: 25))));
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Social login buttons (Google and Facebook) with callback support.
class SocialLoginButtons extends StatelessWidget {
  /// Label for the divider text.
  final String dividerText;

  /// Google button label.
  final String googleLabel;

  /// Facebook button label.
  final String facebookLabel;

  /// Whether dark mode is active.
  final bool isDark;

  /// Callback when Google button is tapped.
  final VoidCallback? onGoogleTap;

  /// Callback when Facebook button is tapped.
  final VoidCallback? onFacebookTap;

  /// Creates SocialLoginButtons.
  const SocialLoginButtons({
    super.key,
    required this.dividerText,
    required this.googleLabel,
    required this.facebookLabel,
    required this.isDark,
    this.onGoogleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDivider(),
        const SizedBox(height: 20),
        _buildSocialButton(
          label: googleLabel,
          icon: Icons.g_mobiledata,
          color: const Color(0xFFDB4437),
          onTap: onGoogleTap ?? () {},
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          label: facebookLabel,
          icon: Icons.facebook,
          color: const Color(0xFF4267B2),
          onTap: onFacebookTap ?? () {},
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: IndieFolkTheme.surface(isDark))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(dividerText,
              style: IndieFolkTheme.body(isDark).copyWith(
                  color: IndieFolkTheme.secondary(isDark), fontSize: 13)),
        ),
        Expanded(child: Divider(color: IndieFolkTheme.surface(isDark))),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: IndieFolkTheme.surface(isDark),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(label,
                style: IndieFolkTheme.body(isDark).copyWith(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

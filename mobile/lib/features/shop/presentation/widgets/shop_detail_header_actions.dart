import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the action buttons (Call & Email) in the shop detail header.
class ShopDetailHeaderActions extends StatelessWidget {
  final String phone;
  final String email;
  final bool isDark;
  final bool isVi;

  const ShopDetailHeaderActions({
    super.key,
    required this.phone,
    required this.email,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final btnStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
    );
    final textStyle = TextStyle(color: isDark ? Colors.white70 : Colors.black87);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final url = Uri.parse('tel:$phone');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
            icon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
            label: Text(isVi ? 'Gọi điện' : 'Call', style: textStyle),
            style: btnStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final url = Uri.parse('mailto:$email');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
            icon: const Icon(Icons.mail_outline, size: 18, color: AppColors.primary),
            label: Text(isVi ? 'Gửi Email' : 'Email', style: textStyle),
            style: btnStyle,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dismissable tip banner for the product management page.
/// Shows info about the "copy product" feature.
class ProductInfoBanner extends StatelessWidget {
  /// Whether to show Vietnamese text.
  final bool isVi;

  /// Whether the theme is dark.
  final bool isDark;

  /// Called when the user dismisses the banner.
  final VoidCallback onDismiss;

  /// Creates the ProductInfoBanner widget.
  const ProductInfoBanner({
    super.key,
    required this.isVi,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: isDark
            ? DarkColors.surface
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : Colors.orange.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20,
            color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(
            isVi
                ? 'Tính năng "Sao chép" dùng để sao chép một số '
                  'thông tin từ sản phẩm có sẵn, hỗ trợ cho việc '
                  'đăng sản phẩm mới một cách nhanh chóng '
                  '(Tính năng "Sao chép" nằm trong nút "...")'
                : 'Use "Copy" to duplicate product info for '
                  'faster product listing (found in "..." menu)',
            style: TextStyle(fontSize: 12, height: 1.4,
              color: isDark
                  ? DarkColors.textPrimary
                  : Colors.brown.shade700))),
          InkWell(onTap: onDismiss,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16,
                color: isDark
                    ? DarkColors.textSecondary
                    : Colors.grey.shade600))),
        ]));
  }
}

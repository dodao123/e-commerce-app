import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Static helper widgets for the identity verification step.
class IdentityHelpers {
  IdentityHelpers._();

  /// Information banner about identity documents.
  static Widget infoBanner(bool isDark, bool isVi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary.withOpacity(0.1)
            : const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 22,
              color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(
            isVi ? 'Vui lòng cung cấp Thông Tin Định Danh '
                'của Chủ Shop (nếu là cá nhân) hoặc Người '
                'Đại Diện Pháp Lý trên giấy đăng ký KD.'
              : 'Please provide identity info of the shop '
                'owner or legal representative.',
            style: TextStyle(fontSize: 12, height: 1.5,
                color: isDark ? DarkColors.textPrimary
                    : Colors.brown.shade700))),
        ]));
  }

  /// Section title text.
  static Widget sectionTitle(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? DarkColors.textPrimary
            : Colors.black87));
  }
}

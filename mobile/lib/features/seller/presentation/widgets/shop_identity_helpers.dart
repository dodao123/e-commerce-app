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

  /// Nationality / tap-to-select field.
  static Widget tapField(
      String label, String value, bool isDark) {
    return InkWell(onTap: () {},
      child: Row(children: [
        Text('$label *', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87)),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 18,
            color: isDark ? DarkColors.textSecondary
                : Colors.grey.shade400),
      ]));
  }

  /// Section title text.
  static Widget sectionTitle(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? DarkColors.textPrimary
            : Colors.black87));
  }

  /// CCCD front/back photo upload boxes + badge icon.
  static Widget photoUploadRow(bool isDark, bool isVi) {
    return Row(children: [
      _photoBox(isVi ? 'Mặt Trước' : 'Front', isDark),
      const SizedBox(width: 12),
      _photoBox(isVi ? 'Mặt sau' : 'Back', isDark),
      const SizedBox(width: 16),
      Container(width: 60, height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.badge_outlined, size: 36,
            color: AppColors.primary)),
    ]);
  }

  /// Hint text about photo quality.
  static Widget photoHint(bool isDark, bool isVi) {
    return Text(
      isVi ? 'Vui lòng cung cấp ảnh chụp cận CCCD. '
          'Thông tin phải rõ ràng, không trong bao nhựa.'
        : 'Please provide clear photos of your ID card. '
          'No plastic covers.',
      style: TextStyle(fontSize: 11, height: 1.4,
          color: isDark ? DarkColors.textSecondary
              : Colors.grey.shade500));
  }

  /// Biometric verification row.
  static Widget biometricRow(bool isDark, bool isVi) {
    return Row(children: [
      Expanded(child: Text(
          isVi ? 'Xác thực sinh trắc học *'
              : 'Biometric Verification *',
          style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary
                  : Colors.black87))),
      InkWell(onTap: () {},
        child: Text(isVi ? 'Xác minh ngay' : 'Verify now',
            style: const TextStyle(color: AppColors.primary,
                fontSize: 13, fontWeight: FontWeight.w600))),
      const Icon(Icons.chevron_right, size: 16,
          color: AppColors.primary),
    ]);
  }

  /// Text input field with label.
  static Widget inputField(
      String label, bool isDark, bool isVi) {
    return Row(children: [
      Expanded(child: Text(label, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: isDark ? DarkColors.textPrimary
              : Colors.black87))),
      Text(isVi ? 'Nhập' : 'Enter',
          style: TextStyle(fontSize: 14,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade400)),
    ]);
  }

  static Widget _photoBox(String label, bool isDark) {
    return GestureDetector(onTap: () {},
      child: Container(width: 80, height: 70,
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : null,
          border: Border.all(color: isDark
              ? DarkColors.textSecondary.withOpacity(0.3)
              : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24, color: isDark
                ? DarkColors.textSecondary
                : Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10,
                color: isDark ? DarkColors.textSecondary
                    : Colors.grey.shade500))])));
  }
}

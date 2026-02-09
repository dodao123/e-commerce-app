import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'shop_identity_helpers.dart';

/// Step 2: Identity verification — Shopee-style layout.
/// Info banner, nationality, CCCD photos, biometric, personal info.
class ShopIdentityStep extends StatelessWidget {
  /// Creates the ShopIdentityStep widget.
  const ShopIdentityStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return ListView(
      padding: const EdgeInsets.all(16), children: [
        IdentityHelpers.infoBanner(isDark, isVi),
        const SizedBox(height: 20),
        IdentityHelpers.tapField(
            isVi ? 'Quốc Tịch' : 'Nationality',
            isVi ? 'Việt Nam' : 'Vietnam', isDark),
        Divider(height: 32, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        IdentityHelpers.sectionTitle(
            isVi ? 'Hình chụp mặt trước CCCD *'
                : 'ID Card Photos *', isDark),
        const SizedBox(height: 12),
        IdentityHelpers.photoUploadRow(isDark, isVi),
        const SizedBox(height: 8),
        IdentityHelpers.photoHint(isDark, isVi),
        Divider(height: 32, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        IdentityHelpers.biometricRow(isDark, isVi),
        Divider(height: 32, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        IdentityHelpers.inputField(
            isVi ? 'Số Căn Cước Công Dân (CCCD) *'
                : 'National ID Number *', isDark, isVi),
        Divider(height: 32, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        IdentityHelpers.inputField(
            isVi ? 'Họ & Tên *' : 'Full Name *',
            isDark, isVi),
        const SizedBox(height: 8),
        Text(isVi ? 'Theo CCCD/Hộ Chiếu'
            : 'As per ID/Passport',
            style: TextStyle(fontSize: 11,
                color: isDark ? DarkColors.textSecondary
                    : Colors.grey.shade500)),
      ]);
  }
}

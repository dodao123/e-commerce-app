import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

/// Guards buyer-only actions by checking the user's role.
/// Shows a styled SnackBar if the user is not a buyer.
class RoleGuard {
  RoleGuard._();

  /// Returns `true` if the current user has the buyer role.
  /// Otherwise shows a warning SnackBar and returns `false`.
  static bool checkBuyerRole(BuildContext context) {
    final role = context.read<AuthProvider>().userRole;
    if (role == 'buyer') return true;

    _showRoleWarning(context);
    return false;
  }

  /// Displays a localized warning SnackBar.
  static void _showRoleWarning(BuildContext context) {
    final isVi = context
        .read<AppProvider>()
        .locale
        .languageCode == 'vi';

    final message = isVi
        ? 'Vui lòng chuyển sang tài khoản khách hàng'
            ' để thực hiện hành động'
        : 'Please switch to a customer account'
            ' to perform this action';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
  }
}

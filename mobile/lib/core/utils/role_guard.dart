import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

/// Guards buyer-only actions by checking the user's role and auth status.
class RoleGuard {
  RoleGuard._();

  /// Returns `true` if the current user is logged in with buyer role.
  /// If unauthenticated, navigates to LoginPage. If non-buyer, shows warning.
  static bool checkBuyerRole(BuildContext context) {
    final auth = context.read<AuthProvider>();

    // 1. Unauthenticated user -> Prompt login and navigate to LoginPage
    if (!auth.isLoggedIn) {
      _showLoginRequiredNotice(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return false;
    }

    // 2. Authenticated but not a buyer (e.g. seller or driver)
    if (auth.userRole != 'buyer') {
      _showRoleWarning(context);
      return false;
    }

    return true;
  }

  /// Displays a SnackBar prompting the user to log in.
  static void _showLoginRequiredNotice(BuildContext context) {
    final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
    final message = isVi
        ? 'Vui lòng đăng nhập để thực hiện hành động này'
        : 'Please log in to perform this action';

    _showSnackBar(context, message);
  }

  /// Displays a localized warning SnackBar for incorrect role.
  static void _showRoleWarning(BuildContext context) {
    final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
    final message = isVi
        ? 'Vui lòng chuyển sang tài khoản khách hàng để thực hiện hành động'
        : 'Please switch to a customer account to perform this action';

    _showSnackBar(context, message);
  }

  /// Helper to display floating SnackBar with consistent theme.
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ));
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Reusable action widgets for the login page.
class LoginActions {
  LoginActions._();

  static Widget buildLoginButton(BuildContext context, bool isVi, bool isDark, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: IndieFolkTheme.tertiary(isDark),
          foregroundColor: IndieFolkTheme.onPrimary(isDark),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: Text(
          isVi ? 'Đăng Nhập' : 'Login To Continue',
          style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600, color: IndieFolkTheme.onPrimary(isDark)),
        ),
      ),
    );
  }

  static Widget buildForgotPassword(bool isVi, bool isDark) {
    return TextButton(
      onPressed: () {},
      child: Text(
        isVi ? 'Quên mật khẩu?' : 'Forgot Password?',
        style: IndieFolkTheme.body(isDark).copyWith(
            color: IndieFolkTheme.tertiary(isDark), fontWeight: FontWeight.w500),
      ),
    );
  }
}

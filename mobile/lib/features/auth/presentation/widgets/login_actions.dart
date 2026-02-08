import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable action widgets for the login page.
class LoginActions {
  LoginActions._();

  /// Builds the primary login button.
  static Widget buildLoginButton(bool isVi, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D2D3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          isVi ? 'Đăng Nhập' : 'Login To Continue',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Builds the "Forgot Password?" link.
  static Widget buildForgotPassword(bool isVi) {
    return TextButton(
      onPressed: () {},
      child: Text(
        isVi ? 'Quên mật khẩu?' : 'Forgot Password?',
        style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Builds the "Not registered? Register" row.
  static Widget buildRegisterRow(bool isVi) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isVi ? 'Chưa có tài khoản? ' : 'Not yet registered! ',
            style: const TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () {},
          child: Text(isVi ? 'Đăng Ký' : 'Register',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }
}

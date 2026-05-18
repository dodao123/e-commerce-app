import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Helper widgets for the register page form fields and button.
class RegisterFormWidgets {
  RegisterFormWidgets._();

  /// Builds a styled text field for the register form.
  static Widget buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isPassword,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscure,
      keyboardType: isPassword ? null : TextInputType.emailAddress,
      style: IndieFolkTheme.body(isDark),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: IndieFolkTheme.secondary(isDark)),
        hintText: hint,
        hintStyle: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.secondary(isDark)),
        filled: true,
        fillColor: IndieFolkTheme.surface(isDark),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure
                    ? Icons.visibility_off
                    : Icons.visibility, color: IndieFolkTheme.secondary(isDark)),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Builds the register submit button.
  static Widget buildRegisterButton(bool isVi, bool isDark, bool isLoading,
      VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: IndieFolkTheme.tertiary(isDark),
          foregroundColor: IndieFolkTheme.onPrimary(isDark),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: IndieFolkTheme.onPrimary(isDark)))
            : Text(isVi ? 'Đăng Ký' : 'Register',
                style: IndieFolkTheme.body(isDark).copyWith(
                    fontWeight: FontWeight.w600, color: IndieFolkTheme.onPrimary(isDark))),
      ),
    );
  }
}

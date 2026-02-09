import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscure,
      keyboardType: isPassword ? null : TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Builds the register submit button.
  static Widget buildRegisterButton(bool isVi, bool isLoading,
      VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D2D3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(isVi ? 'Đăng Ký' : 'Register',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

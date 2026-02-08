import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/login_header.dart';


/// Register page with email, password, and social login.
class RegisterPage extends StatefulWidget {
  /// Creates the RegisterPage widget.
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(children: [
              LoginHeader(
                title: isVi ? 'Đăng Ký' : 'Register',
                subtitle: isVi
                    ? 'Tạo tài khoản mới bằng email\nvà mật khẩu của bạn.'
                    : 'Create a new account using your\nemail and password.',
              ),
              _buildBackButton(),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(children: [
                _buildField(_emailController, Icons.email_outlined,
                    isVi ? 'Nhập email' : 'Enter email', false),
                const SizedBox(height: 16),
                _buildField(_passwordController, Icons.lock_outline,
                    isVi ? 'Nhập mật khẩu' : 'Enter password', true),
                const SizedBox(height: 16),
                _buildField(_confirmController, Icons.lock_outline,
                    isVi ? 'Xác nhận mật khẩu' : 'Confirm password', true),
                const SizedBox(height: 24),
                _buildRegisterButton(isVi),
                const SizedBox(height: 24),
                _buildLoginRow(isVi),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(top: 50, left: 10,
      child: IconButton(onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white)));
  }

  Widget _buildField(TextEditingController ctrl, IconData icon,
      String hint, bool isPwd) {
    return TextField(controller: ctrl,
      obscureText: isPwd && _obscurePassword,
      keyboardType: isPwd ? null : TextInputType.emailAddress,
      decoration: InputDecoration(prefixIcon: Icon(icon), hintText: hint,
        suffixIcon: isPwd ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)));
  }

  Widget _buildRegisterButton(bool isVi) {
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00D2D3), foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0),
      child: Text(isVi ? 'Đăng Ký' : 'Register',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));
  }

  Widget _buildLoginRow(bool isVi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DAFA), width: 1.2),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(isVi ? 'Đã có tài khoản? ' : 'Already have an account? ',
          style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(isVi ? 'Đăng Nhập' : 'Login',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF4A3ADB),
            )),
        ),
      ]),
    );
  }
}

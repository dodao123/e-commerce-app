import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_input_fields.dart';
import '../widgets/login_actions.dart';
import '../widgets/login_header.dart';
import '../widgets/social_login_buttons.dart';
import 'register_page.dart';
import 'role_selection_page.dart';

/// Login page with email/password and social login.
class LoginPage extends StatefulWidget {
  /// Creates the LoginPage widget.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(children: [
            Stack(children: [
              LoginHeader(
                title: isVi ? 'Đăng Nhập' : 'Sign In',
                subtitle: isVi
                    ? 'Đăng nhập tài khoản bằng email\nvà mật khẩu của bạn.'
                    : 'Login to your account using your\nemail and password.',
              ),
              Positioned(
                top: 58, left: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(children: [
                AuthInputFields.buildEmailField(
                  controller: _emailCtrl,
                  hintText: isVi ? 'Nhập email' : 'Enter email',
                ),
                const SizedBox(height: 8),
                AuthInputFields.buildPasswordField(
                  controller: _passwordCtrl,
                  hintText: isVi ? 'Nhập mật khẩu' : 'Enter password',
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 16),
                LoginActions.buildLoginButton(isVi, () {}),
                const SizedBox(height: 4),
                LoginActions.buildForgotPassword(isVi),
                const SizedBox(height: 4),
                SocialLoginButtons(
                  dividerText: isVi ? 'Hoặc đăng nhập với' : 'Or sign in with',
                  googleLabel: 'Google',
                  facebookLabel: 'Facebook',
                  onGoogleTap: () => _socialLogin(auth.signInWithGoogle, auth),
                  onFacebookTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isVi
                            ? 'Facebook Login sẽ sớm ra mắt!'
                            : 'Facebook Login coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildRegisterRow(isVi),
              ]),
            ),
          ]),
        ),
        if (auth.isLoading) _buildLoadingOverlay(),
      ]),
    );
  }

  Future<void> _socialLogin(
    Future<bool> Function() loginFn, AuthProvider auth,
  ) async {
    final ok = await loginFn();
    if (ok && mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()));
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  Widget _buildRegisterRow(bool isVi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DAFA), width: 1.2),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(isVi ? 'Chưa có tài khoản? ' : 'Not yet registered? ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegisterPage())),
          child: Text(isVi ? 'Đăng Ký' : 'Register',
            style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15,
              color: Color(0xFF4A3ADB)))),
      ]),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

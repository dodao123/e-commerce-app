import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/login_actions.dart';
import '../widgets/login_header.dart';
import '../widgets/social_login_buttons.dart';
import 'register_page.dart';
import 'role_selection_page.dart';

/// Login page with email/password and social login.
class LoginPage extends StatefulWidget {
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

  /// Navigate based on role selection status.
  void _onAuthSuccess() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.hasSelectedRole) {
      // Already selected role before — go to home
      Navigator.pop(context);
    } else {
      // First time — choose role
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()));
    }
  }

  Future<void> _handleEmailLogin() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    if (ok) _onAuthSuccess();
  }

  Future<void> _handleGoogle() async {
    final ok = await context.read<AuthProvider>().signInWithGoogle();
    if (ok) _onAuthSuccess();
  }

  Future<void> _handleFacebook() async {
    final ok = await context.read<AuthProvider>().signInWithFacebook();
    if (ok) _onAuthSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(children: [
            Stack(children: [
              LoginHeader(
                title: isVi ? 'Đăng Nhập' : 'Sign In',
                subtitle: isVi
                    ? 'Đăng nhập bằng email\nvà mật khẩu của bạn.'
                    : 'Login with your email\nand password.',
                isDark: isDark),
              AuthBackButton(isDark: isDark),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(children: [
                if (auth.errorMessage != null)
                  _buildError(auth.errorMessage!, isDark),
                _buildEmail(isVi, isDark),
                const SizedBox(height: 12),
                _buildPassword(isVi, isDark),
                const SizedBox(height: 16),
                LoginActions.buildLoginButton(
                    context, isVi, isDark, auth.isLoading ? null : _handleEmailLogin),
                const SizedBox(height: 8),
                LoginActions.buildForgotPassword(isVi, isDark),
                const SizedBox(height: 10),
                SocialLoginButtons(
                  isDark: isDark,
                  dividerText: isVi ? 'Hoặc đăng nhập với' : 'Or sign in with',
                  googleLabel: 'Google', facebookLabel: 'Facebook',
                  onGoogleTap: auth.isLoading ? null : _handleGoogle,
                  onFacebookTap: auth.isLoading ? null : _handleFacebook),
                const SizedBox(height: 16),
                _buildRegisterRow(isVi, isDark),
              ])),
          ]),
        ),
        if (auth.isLoading) _buildLoadingOverlay(),
      ]),
    );
  }


  Widget _buildLoadingOverlay() {
    final isVi = context.read<AppProvider>()
        .locale.languageCode == 'vi';
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
              color: Colors.white),
          const SizedBox(height: 16),
          Text(isVi ? 'Đang đăng nhập...'
              : 'Signing in...',
              style: const TextStyle(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ])));
  }

  Widget _buildError(String msg, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(msg, style: IndieFolkTheme.body(isDark).copyWith(color: Colors.red)));

  Widget _buildEmail(bool isVi, bool isDark) => TextField(
    controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
    style: IndieFolkTheme.body(isDark),
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.email_outlined, color: IndieFolkTheme.secondary(isDark)),
      hintText: isVi ? 'Nhập email' : 'Enter email',
      hintStyle: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.secondary(isDark)),
      filled: true,
      fillColor: IndieFolkTheme.surface(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)));

  Widget _buildPassword(bool isVi, bool isDark) => TextField(
    controller: _passwordCtrl, obscureText: _obscure,
    style: IndieFolkTheme.body(isDark),
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.lock_outline, color: IndieFolkTheme.secondary(isDark)),
      hintText: isVi ? 'Nhập mật khẩu' : 'Enter password',
      hintStyle: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.secondary(isDark)),
      filled: true,
      fillColor: IndieFolkTheme.surface(isDark),
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: IndieFolkTheme.secondary(isDark)),
        onPressed: () => setState(() => _obscure = !_obscure)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)));

  Widget _buildRegisterRow(bool isVi, bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(isVi ? 'Chưa có tài khoản? ' : 'Not yet registered! ',
        style: IndieFolkTheme.body(isDark)),
      GestureDetector(onTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RegisterPage())),
        child: Text(isVi ? 'Đăng Ký' : 'Register',
          style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.bold, color: IndieFolkTheme.tertiary(isDark))))]);
}

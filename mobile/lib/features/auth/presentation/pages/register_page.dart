import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/login_header.dart';
import '../widgets/register_form_widgets.dart';
import 'login_page.dart';
import 'role_selection_page.dart';

/// Register page with email, password, and social login.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Navigate based on role selection status.
  void _onAuthSuccess() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.hasSelectedRole) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()));
    }
  }

  Future<void> _handleRegister() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Passwords do not match')));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _nameCtrl.text.trim(),
    );
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

  Widget _buildLoginRow(bool isVi) => Row(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(isVi ? 'Đã có tài khoản? ' : 'Already have an account? '),
      GestureDetector(onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginPage())),
        child: Text(isVi ? 'Đăng Nhập' : 'Login',
          style: const TextStyle(fontWeight: FontWeight.bold)))]);

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final auth = context.watch<AuthProvider>();
    final toggle = () => setState(() => _obscure = !_obscure);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            LoginHeader(
              title: isVi ? 'Đăng Ký' : 'Register',
              subtitle: isVi
                  ? 'Tạo tài khoản mới bằng email\nvà mật khẩu.'
                  : 'Create a new account with\nemail and password.'),
            const AuthBackButton(),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Column(children: [
              if (auth.errorMessage != null)
                Padding(padding: const EdgeInsets.only(bottom: 16),
                  child: Text(auth.errorMessage!,
                    style: const TextStyle(color: Colors.red))),
              RegisterFormWidgets.buildField(controller: _nameCtrl,
                icon: Icons.person_outline,
                hint: isVi ? 'Họ và tên' : 'Full name',
                isPassword: false, obscure: _obscure, onToggle: toggle),
              const SizedBox(height: 16),
              RegisterFormWidgets.buildField(controller: _emailCtrl,
                icon: Icons.email_outlined, hint: 'Email',
                isPassword: false, obscure: _obscure, onToggle: toggle),
              const SizedBox(height: 16),
              RegisterFormWidgets.buildField(controller: _passwordCtrl,
                icon: Icons.lock_outline,
                hint: isVi ? 'Mật khẩu' : 'Password',
                isPassword: true, obscure: _obscure, onToggle: toggle),
              const SizedBox(height: 16),
              RegisterFormWidgets.buildField(controller: _confirmCtrl,
                icon: Icons.lock_outline,
                hint: isVi ? 'Xác nhận mật khẩu' : 'Confirm password',
                isPassword: true, obscure: _obscure, onToggle: toggle),
              const SizedBox(height: 24),
              RegisterFormWidgets.buildRegisterButton(
                  isVi, auth.isLoading, _handleRegister),
              const SizedBox(height: 20),
              _buildLoginRow(isVi),
            ])),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_icon_key_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Custom app bar with settings, search, cart, and login/profile.
class HomeAppBar extends StatelessWidget {
  /// Creates the HomeAppBar widget.
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartKey = context.read<CartIconKeyProvider>().cartIconKey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: isDark ? DarkColors.background : null,
      child: Row(children: [
        // Settings button
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsPage())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? DarkColors.surface
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.settings, size: 22,
                color: isDark ? DarkColors.textPrimary : Colors.black87)),
        ),
        const Spacer(),
        // Search
        IconButton(onPressed: () {},
            icon: const Icon(Icons.search, size: 26)),
        // Cart — GlobalKey for fly-to-cart animation target
        Stack(key: cartKey, children: [
          IconButton(onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined, size: 24)),
          Positioned(right: 6, top: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
              child: const Center(
                child: Text('0', style: TextStyle(
                    color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.bold))),
            )),
        ]),
        const SizedBox(width: 4),
        // Avatar or Login
        auth.isLoggedIn
            ? _buildProfileChip(auth, context)
            : _buildLoginButton(isVi, context),
      ]),
    );
  }

  Widget _buildLoginButton(bool isVi, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20)),
        child: Text(isVi ? 'Đăng Nhập' : 'Log In',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildProfileChip(AuthProvider auth, BuildContext context) {
    final hasAvatar = auth.avatarUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => _showLogoutDialog(auth, context),
      child: CircleAvatar(
        radius: 18, backgroundColor: AppColors.primary,
        backgroundImage: hasAvatar ? NetworkImage(auth.avatarUrl) : null,
        child: hasAvatar ? null : Text(
          auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  void _showLogoutDialog(AuthProvider auth, BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(auth.userName), content: Text(auth.userEmail),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        TextButton(
          onPressed: () { auth.signOut(); Navigator.pop(context); },
          child: const Text('Logout',
              style: TextStyle(color: Colors.red))),
      ]));
  }
}

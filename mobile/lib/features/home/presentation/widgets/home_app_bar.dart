import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_icon_key_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/utils/role_guard.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../search/presentation/pages/search_results_page.dart';
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
        IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchResultsPage())),
            icon: const Icon(Icons.search, size: 26)),
        // Cart — GlobalKey for fly-to-cart animation target
        Stack(key: cartKey, children: [
          IconButton(onPressed: () {
              if (!RoleGuard.checkBuyerRole(context)) return;
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CartPage()));
            },
              icon: const Icon(Icons.shopping_cart_outlined, size: 24)),
          Positioned(right: 6, top: 6,
            child: _buildCartBadge(context)),
        ]),
        const SizedBox(width: 4),
        // Avatar or Login
        auth.isLoggedIn
            ? _buildProfileChip(auth, context, isVi, isDark)
            : _buildLoginButton(isVi, context, isDark),
      ]),
    );
  }

  Widget _buildLoginButton(bool isVi, BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: IndieFolkTheme.tertiary(isDark),
          borderRadius: BorderRadius.circular(6)),
        child: Text(isVi ? 'Đăng Nhập' : 'Log In',
            style: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.onPrimary(isDark),
                fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildProfileChip(AuthProvider auth, BuildContext context, bool isVi, bool isDark) {
    final hasAvatar = auth.avatarUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => _showLogoutDialog(auth, context, isVi, isDark),
      child: CircleAvatar(
        radius: 18, backgroundColor: IndieFolkTheme.tertiary(isDark),
        backgroundImage: hasAvatar ? NetworkImage(auth.avatarUrl) : null,
        child: hasAvatar ? null : Text(
          auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
          style: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.onPrimary(isDark),
              fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  void _showLogoutDialog(AuthProvider auth, BuildContext context, bool isVi, bool isDark) {
    final hasAvatar = auth.avatarUrl.isNotEmpty;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: IndieFolkTheme.surface(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Column(
        children: [
          CircleAvatar(
            radius: 30, backgroundColor: IndieFolkTheme.tertiary(isDark),
            backgroundImage: hasAvatar ? NetworkImage(auth.avatarUrl) : null,
            child: hasAvatar ? null : Text(
              auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
              style: IndieFolkTheme.h1(isDark).copyWith(color: IndieFolkTheme.onPrimary(isDark),
                  fontWeight: FontWeight.bold, fontSize: 28))),
          const SizedBox(height: 16),
          Text(auth.userName.isNotEmpty ? auth.userName : (isVi ? 'Tài khoản' : 'Account'),
              style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 22)),
        ],
      ),
      content: Text(auth.userEmail, textAlign: TextAlign.center, style: IndieFolkTheme.body(isDark)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: IndieFolkTheme.primary(isDark),
            side: BorderSide(color: IndieFolkTheme.primary(isDark).withValues(alpha: 0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(isVi ? 'Đóng' : 'Close', style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600))),
        FilledButton(
          onPressed: () { auth.signOut(); Navigator.pop(context); },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(isVi ? 'Đăng xuất' : 'Logout',
              style: IndieFolkTheme.body(isDark).copyWith(color: Colors.white, fontWeight: FontWeight.w600))),
      ]));
  }

  /// Builds the cart badge with live count from CartProvider.
  Widget _buildCartBadge(BuildContext context) {
    final count = context.watch<CartProvider>().totalCount;
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      width: 16, height: 16,
      decoration: const BoxDecoration(
        color: AppColors.primary, shape: BoxShape.circle),
      child: Center(
        child: Text('$count', style: const TextStyle(
            color: Colors.white, fontSize: 10,
            fontWeight: FontWeight.bold))),
    );
  }
}

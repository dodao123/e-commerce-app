import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/menu_profile_header.dart';
import '../widgets/menu_order_tracking.dart';
import '../widgets/menu_utilities.dart';
import '../widgets/menu_support.dart';
import '../widgets/menu_role_upgrade.dart';
import '../widgets/menu_product_suggestions.dart';
import 'seller_menu_content.dart';

/// Menu page — displays role-based content.
/// Buyer: orders, utilities, support, suggestions.
/// Seller: shop profile, order stats, seller tools, promos.
class MenuPage extends StatelessWidget {
  /// Creates the MenuPage widget.
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) return _buildLoginPrompt(context, isVi);

    // Route by role
    if (auth.userRole == 'seller') {
      return SellerMenuContent(
        isVi: isVi,
        shopName: auth.userName,
        shopEmail: auth.userEmail,
        avatarUrl: auth.avatarUrl);
    }

    return _buildBuyerMenu(auth, isVi);
  }

  Widget _buildBuyerMenu(AuthProvider auth, bool isVi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(children: [
        MenuProfileHeader(
          userName: auth.userName,
          userEmail: auth.userEmail,
          avatarUrl: auth.avatarUrl,
          roleLabel: _roleLabel(auth.userRole, isVi)),
        const SizedBox(height: 16),
        MenuOrderTracking(isVi: isVi),
        const SizedBox(height: 16),
        MenuUtilities(isVi: isVi),
        const SizedBox(height: 16),
        MenuSupport(isVi: isVi),
        const SizedBox(height: 16),
        MenuRoleUpgrade(isVi: isVi),
        const SizedBox(height: 20),
        MenuProductSuggestions(isVi: isVi),
      ]),
    );
  }

  String _roleLabel(String role, bool isVi) {
    switch (role) {
      case 'buyer': return isVi ? 'Người mua' : 'Buyer';
      case 'seller': return isVi ? 'Người bán' : 'Seller';
      case 'driver': return isVi ? 'Tài xế' : 'Driver';
      default: return isVi ? 'Thành viên' : 'Member';
    }
  }

  Widget _buildLoginPrompt(BuildContext context, bool isVi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64,
              color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(isVi ? 'Đăng nhập để xem menu' : 'Login to view menu',
              style: TextStyle(fontSize: 16,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LoginPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF6C4A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
            child: Text(isVi ? 'Đăng Nhập' : 'Log In')),
        ]),
    );
  }
}

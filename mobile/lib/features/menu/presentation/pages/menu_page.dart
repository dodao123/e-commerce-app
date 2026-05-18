import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../seller/data/shop_remote_datasource.dart';
import '../widgets/menu_profile_header.dart';
import '../widgets/menu_order_tracking.dart';
import '../widgets/menu_utilities.dart';
import '../widgets/menu_support.dart';
import '../widgets/menu_role_upgrade.dart';
import '../widgets/menu_product_suggestions.dart';
import 'seller_menu_content.dart';

/// Menu page — displays role-based content.
class MenuPage extends StatefulWidget {
  /// Creates the MenuPage widget.
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _fetchShopId();
  }

  Future<void> _fetchShopId() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) return;
      final ds = ShopRemoteDatasource();
      final shop = await ds.getMyShop(token: token);
      if (shop != null && mounted) {
        setState(() =>
            _shopId = shop['id']?.toString() ?? '');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return _buildLoginPrompt(context, isVi);
    }

    if (auth.userRole == 'seller') {
      return SellerMenuContent(
        isVi: isVi,
        shopName: auth.userName,
        shopEmail: auth.userEmail,
        avatarUrl: auth.avatarUrl,
        shopId: _shopId);
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
      ]));
  }

  String _roleLabel(String role, bool isVi) {
    switch (role) {
      case 'buyer': return isVi ? 'Người mua' : 'Buyer';
      case 'seller': return isVi ? 'Người bán' : 'Seller';
      case 'driver': return isVi ? 'Tài xế' : 'Driver';
      default: return isVi ? 'Thành viên' : 'Member';
    }
  }

  Widget _buildLoginPrompt(
      BuildContext context, bool isVi) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 64,
            color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(isVi ? 'Đăng nhập để xem menu'
            : 'Login to view menu',
            style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontSize: 16,
                color: IndieFolkTheme.secondary(Theme.of(context).brightness == Brightness.dark))),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const LoginPage())),
          style: ElevatedButton.styleFrom(
            backgroundColor: IndieFolkTheme.tertiary(Theme.of(context).brightness == Brightness.dark),
            foregroundColor: IndieFolkTheme.onPrimary(Theme.of(context).brightness == Brightness.dark),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(6))),
          child: Text(
              isVi ? 'Đăng Nhập' : 'Log In',
              style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontWeight: FontWeight.w600))),
      ]));
  }
}

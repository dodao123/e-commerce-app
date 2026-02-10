import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/shop_remote_datasource.dart';
import 'shop_dashboard_page.dart';
import 'shop_welcome_page.dart';

/// Router page that checks if the seller already has a shop.
/// Shows dashboard if shop exists, or welcome page if not.
class ShopRouterPage extends StatefulWidget {
  /// Creates a ShopRouterPage widget.
  const ShopRouterPage({super.key});

  @override
  State<ShopRouterPage> createState() => _ShopRouterPageState();
}

class _ShopRouterPageState extends State<ShopRouterPage> {
  final _datasource = ShopRemoteDatasource();
  bool _isLoading = true;
  Map<String, dynamic>? _shopData;

  @override
  void initState() {
    super.initState();
    _checkShop();
  }

  /// Check if seller already has a shop in the DB.
  Future<void> _checkShop() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final shop = await _datasource.getMyShop(token: token);
      if (mounted) {
        setState(() {
          _shopData = shop;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _loadingScreen(context);

    if (_shopData != null) {
      return ShopDashboardPage(shopData: _shopData!);
    }

    return const ShopWelcomePage();
  }

  Widget _loadingScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary)));
  }
}

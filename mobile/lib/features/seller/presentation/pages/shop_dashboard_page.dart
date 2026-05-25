import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../widgets/shop_quick_actions.dart';
import 'edit_shop_info_page.dart';
import '../../../../core/storage/token_manager.dart';
import '../../data/shop_remote_datasource.dart';

/// Dashboard page for seller's shop management.
/// Shows shop info summary and quick action buttons.
class ShopDashboardPage extends StatefulWidget {
  /// Shop data from the API.
  final Map<String, dynamic> shopData;

  /// Creates a ShopDashboardPage widget.
  const ShopDashboardPage({super.key, required this.shopData});

  @override
  State<ShopDashboardPage> createState() => _ShopDashboardPageState();
}

class _ShopDashboardPageState extends State<ShopDashboardPage> {
  late Map<String, dynamic> _shopData;

  @override
  void initState() {
    super.initState();
    _shopData = widget.shopData;
  }

  Future<void> _refreshShopInfo() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) return;
      final shop = await ShopRemoteDatasource().getMyShop(token: token);
      if (shop != null && mounted) {
        setState(() => _shopData = shop);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        backgroundColor: IndieFolkTheme.neutral(isDark),
        elevation: 0,
        title: Text(isVi ? 'Shop của tôi' : 'My Shop',
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 20)),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditShopInfoPage(shopData: _shopData)));
              if (result == true) {
                _refreshShopInfo();
              }
            },
            icon: Icon(Icons.edit_outlined,
              color: IndieFolkTheme.primary(isDark))),
        ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _shopInfoCard(isDark),
          const SizedBox(height: 24),
          ShopQuickActions(
            isVi: isVi, isDark: isDark,
            shopData: _shopData,
            onRefresh: _refreshShopInfo),
        ])));
  }

  Widget _shopInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.store, color: IndieFolkTheme.primary(isDark), size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _shopData['shop_name'] ?? '',
              style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 24))),
          ]),
          const SizedBox(height: 12),
          _infoRow(Icons.email_outlined, _shopData['email'] ?? '', isDark),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_outlined, _shopData['phone'] ?? '', isDark),
          const SizedBox(height: 6),
          _infoRow(Icons.location_on_outlined,
              _shopData['detail_address'] ?? '', isDark),
        ]));
  }

  Widget _infoRow(IconData icon, String text, bool isDark) {
    return Row(children: [
      Icon(icon, size: 16, color: IndieFolkTheme.primary(isDark)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: IndieFolkTheme.body(isDark))),
    ]);
  }
}

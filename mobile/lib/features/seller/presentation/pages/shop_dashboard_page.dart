import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/shop_quick_actions.dart';

/// Dashboard page for seller's shop management.
/// Shows shop info summary and quick action buttons.
class ShopDashboardPage extends StatelessWidget {
  /// Shop data from the API.
  final Map<String, dynamic> shopData;

  /// Creates a ShopDashboardPage widget.
  const ShopDashboardPage({super.key, required this.shopData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? DarkColors.surface : Colors.white,
        elevation: 0.5,
        title: Text(isVi ? 'Shop của tôi' : 'My Shop',
          style: TextStyle(
            color: isDark ? DarkColors.textPrimary : Colors.black87,
            fontSize: 17, fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _shopInfoCard(),
          const SizedBox(height: 24),
          ShopQuickActions(
            isVi: isVi, isDark: isDark,
            shopId: shopData['id']?.toString() ?? ''),
        ])));
  }

  Widget _shopInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF6C4A), Color(0xFFFF8C6B)]),
        borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.store, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(
              shopData['shop_name'] ?? '',
              style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold, color: Colors.white))),
          ]),
          const SizedBox(height: 12),
          _infoRow(Icons.email_outlined, shopData['email'] ?? ''),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_outlined, shopData['phone'] ?? ''),
          const SizedBox(height: 6),
          _infoRow(Icons.location_on_outlined,
              shopData['detail_address'] ?? ''),
        ]));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.white70),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
        style: const TextStyle(fontSize: 13, color: Colors.white70))),
    ]);
  }
}

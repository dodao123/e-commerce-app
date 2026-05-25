import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../seller/presentation/pages/shop_router_page.dart';
import 'seller_mini_stats.dart';

/// Premium seller profile header with gradient and shop stats.
class SellerProfileHeader extends StatelessWidget {
  final String shopName;
  final String shopEmail;
  final String avatarUrl;
  final bool isVi;

  const SellerProfileHeader({
    super.key,
    required this.shopName,
    required this.shopEmail,
    required this.avatarUrl,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConstants.resolveImageUrl(avatarUrl);
    final hasAvatar = resolvedUrl.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6))]),
      child: Column(children: [
        Row(children: [
          _avatar(hasAvatar, resolvedUrl),
          const SizedBox(width: 14),
          _shopInfo(),
          _viewShopButton(context),
        ]),
        const SizedBox(height: 16),
        SellerMiniStats(isVi: isVi),
      ]));
  }

  Widget _avatar(bool hasAvatar, String resolvedUrl) {
    final bool isSvg = resolvedUrl.toLowerCase().endsWith('.svg');
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00D2FF), width: 2)),
      child: CircleAvatar(radius: 28,
        backgroundColor: const Color(0xFF0F3460),
        backgroundImage: (hasAvatar && !isSvg) ? NetworkImage(resolvedUrl) : null,
        child: (hasAvatar && !isSvg) ? null : Text(
          shopName.isNotEmpty ? shopName[0].toUpperCase() : '?',
          style: IndieFolkTheme.h1(true).copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))));
  }

  Widget _shopInfo() {
    return Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(shopName, style: IndieFolkTheme.h1(true).copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(shopEmail, style: IndieFolkTheme.body(true).copyWith(fontSize: 12, color: Colors.white.withOpacity(0.7))),
      ]));
  }

  Widget _viewShopButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopRouterPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)]),
          borderRadius: BorderRadius.circular(6)),
        child: Text(isVi ? 'Xem Shop' : 'View Shop',
            style: IndieFolkTheme.body(true).copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))));
  }
}

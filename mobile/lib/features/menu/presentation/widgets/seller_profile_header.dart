import 'package:flutter/material.dart';
import '../../../seller/presentation/pages/shop_welcome_page.dart';

/// Premium seller profile header with gradient and shop stats.
class SellerProfileHeader extends StatelessWidget {
  /// Shop owner name.
  final String shopName;

  /// Shop owner email.
  final String shopEmail;

  /// Avatar URL.
  final String avatarUrl;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the SellerProfileHeader widget.
  const SellerProfileHeader({
    super.key,
    required this.shopName,
    required this.shopEmail,
    required this.avatarUrl,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6))]),
      child: Column(children: [
        Row(children: [
          _avatar(hasAvatar),
          const SizedBox(width: 14),
          _shopInfo(),
          _viewShopButton(context),
        ]),
        const SizedBox(height: 16),
        _miniStats(),
      ]));
  }

  Widget _avatar(bool hasAvatar) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: const Color(0xFF00D2FF), width: 2)),
      child: CircleAvatar(radius: 28,
        backgroundColor: const Color(0xFF0F3460),
        backgroundImage: hasAvatar
            ? NetworkImage(avatarUrl) : null,
        child: hasAvatar ? null : Text(
          shopName.isNotEmpty
              ? shopName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white,
              fontSize: 22, fontWeight: FontWeight.bold))));
  }

  Widget _shopInfo() {
    return Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(shopName, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold,
            color: Colors.white)),
        const SizedBox(height: 4),
        Text(shopEmail, style: TextStyle(fontSize: 12,
            color: Colors.white.withOpacity(0.7))),
      ]));
  }

  Widget _viewShopButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const ShopWelcomePage())),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF00D2FF), Color(0xFF3A7BD5)]),
          borderRadius: BorderRadius.circular(20)),
        child: Text(isVi ? 'Xem Shop' : 'View Shop',
            style: const TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600))));
  }

  Widget _miniStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stat('128', isVi ? 'Sản phẩm' : 'Products'),
        _divider(),
        _stat('1.2K', isVi ? 'Người theo dõi'
            : 'Followers'),
        _divider(),
        _stat('4.8', isVi ? '⭐ Đánh giá' : '⭐ Rating'),
      ]);
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white,
          fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10,
          color: Colors.white.withOpacity(0.6))),
    ]);
  }

  Widget _divider() {
    return Container(width: 1, height: 30,
        color: Colors.white.withOpacity(0.15));
  }
}

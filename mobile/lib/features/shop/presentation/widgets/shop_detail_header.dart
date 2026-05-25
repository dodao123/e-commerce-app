import 'package:flutter/material.dart';
import 'shop_detail_header_avatar.dart';

/// Renders the core information block of the shop including name, category, statistics, and quick buttons.
class ShopDetailHeader extends StatelessWidget {
  final Map<String, dynamic> shop;
  final int productsCount;
  final bool isDark;
  final bool isVi;

  const ShopDetailHeader({
    super.key,
    required this.shop,
    required this.productsCount,
    required this.isDark,
    required this.isVi,
  });

  String _getDistance() {
    final latVal = shop['lat'];
    final double? lat = latVal is num ? latVal.toDouble() : null;
    if (lat == null) return '2.5 km';
    return '${((lat - 21.01).abs() * 3.5 + 0.5).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShopDetailHeaderAvatar(
          shopId: shop['id'] ?? '',
          avatarUrl: shop['shop_avatar'] ?? '',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shop['shop_name'] ?? '',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.storefront_outlined, size: 16, color: isDark ? Colors.white60 : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${shop['category'] ?? ''} • ${shop['province'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.grey[700]),
                ),
              ]),
              const SizedBox(height: 16),
              _buildStatsRow(),
            ],
          ),
        ),
      ],
    );
  }

  double _getRating(String uuid) {
    if (uuid.isEmpty) return 4.5;
    int sum = 0;
    for (int i = 0; i < uuid.length; i++) {
      sum += uuid.codeUnitAt(i);
    }
    return 3.8 + (sum % 13) * 0.1;
  }

  Widget _buildStatsRow() {
    final labelColor = isDark ? Colors.white60 : Colors.grey[600];
    final valStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(children: [
          Text('$productsCount', style: valStyle),
          Text(isVi ? 'Sản phẩm' : 'Products', style: TextStyle(fontSize: 12, color: labelColor))
        ]),
        Column(children: [
          Text('${_getRating(shop['id'] ?? '').toStringAsFixed(1)}★', style: valStyle),
          Text(isVi ? 'Đánh giá' : 'Stars', style: TextStyle(fontSize: 12, color: labelColor))
        ]),
        Column(children: [
          Text(_getDistance(), style: valStyle),
          Text(isVi ? 'Cách đây' : 'away', style: TextStyle(fontSize: 12, color: labelColor))
        ]),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_item_tile.dart';

/// A group of cart items from the same shop.
/// Shows shop header (avatar + name) followed by item tiles.
class CartShopGroup extends StatelessWidget {
  /// Display name of the shop.
  final String shopName;

  /// Seller's avatar URL.
  final String shopAvatar;

  /// Cart items belonging to this shop.
  final List<CartItemModel> items;

  /// Whether dark theme is active.
  final bool isDark;

  /// Creates the CartShopGroup.
  const CartShopGroup({
    super.key,
    required this.shopName,
    required this.shopAvatar,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShopHeader(),
        const SizedBox(height: 8),
        ...items.map((item) => CartItemTile(
            item: item, isDark: isDark)),
      ],
    );
  }

  Widget _buildShopHeader() {
    return Row(children: [
      _buildAvatar(),
      const SizedBox(width: 8),
      Text(shopName, style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(width: 4),
      Icon(Icons.chevron_right, size: 18,
          color: isDark
              ? DarkColors.textSecondary : Colors.grey),
    ]);
  }

  Widget _buildAvatar() {
    final resolvedUrl = ApiConstants.resolveImageUrl(shopAvatar);
    if (resolvedUrl.isNotEmpty) {
      return CircleAvatar(radius: 12,
        backgroundImage: NetworkImage(resolvedUrl),
        onBackgroundImageError: (_, __) {});
    }
    return CircleAvatar(radius: 12,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(Icons.storefront, size: 14,
          color: AppColors.primary));
  }
}

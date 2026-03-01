import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_shop_group.dart';

/// Scrollable list of cart items grouped by shop.
class CartItemList extends StatelessWidget {
  /// All cart items (will be grouped by shop).
  final List<CartItemModel> items;

  /// Whether dark theme is active.
  final bool isDark;

  /// Creates the CartItemList.
  const CartItemList({
    super.key,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByShop(items);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 24),
      itemBuilder: (_, index) {
        final shopId = grouped.keys.elementAt(index);
        final shopItems = grouped[shopId]!;
        return CartShopGroup(
          shopName: shopItems.first.shopName,
          shopAvatar: shopItems.first.shopAvatar,
          items: shopItems,
          isDark: isDark,
        );
      },
    );
  }

  /// Groups items by their shop ID.
  Map<String, List<CartItemModel>> _groupByShop(
      List<CartItemModel> items) {
    final map = <String, List<CartItemModel>>{};
    for (final item in items) {
      map.putIfAbsent(item.shopId, () => []).add(item);
    }
    return map;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import 'product_price_row.dart';

/// Individual product card in the home grid layout.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  /// Creates a ProductCard for the given product.
  const ProductCard({
    super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Center(child: Padding(
              padding: const EdgeInsets.all(12),
              child: ProductImage(product: product)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.shopName.isNotEmpty)
                    _ShopBadge(product: product, isDark: isDark),
                  Text(product.localizedName(lang),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  ProductPriceRow(
                      product: product, isDark: isDark),
                ])),
          ])));
  }
}

/// Shop name and location badge above product title.
class _ShopBadge extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  const _ShopBadge({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final label = product.shopProvince.isNotEmpty
        ? '${product.shopName} • ${product.shopProvince}'
        : product.shopName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        _buildAvatar(),
        const SizedBox(width: 3),
        Expanded(child: Text(label,
          style: TextStyle(fontSize: 10,
            color: isDark ? DarkColors.textSecondary
                : Colors.grey.shade600),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]));
  }

  Widget _buildAvatar() {
    if (product.shopAvatar.isNotEmpty) {
      return CircleAvatar(radius: 7,
        backgroundImage: NetworkImage(product.shopAvatar),
        onBackgroundImageError: (_, __) {});
    }
    return Icon(Icons.storefront, size: 11,
      color: isDark ? DarkColors.textSecondary : Colors.grey);
  }
}

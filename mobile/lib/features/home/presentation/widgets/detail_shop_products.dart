import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';

/// Horizontal list of other products from the same shop.
class DetailShopProducts extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;

  /// Creates the DetailShopProducts widget.
  const DetailShopProducts({
    super.key, required this.products, this.onProductTap});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Các sản phẩm khác của Shop',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600))),
        SizedBox(height: 140, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _buildItem(
              products[i], isDark))),
      ]);
  }

  Widget _buildItem(ProductModel product, bool isDark) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: SizedBox(width: 110, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110, height: 90,
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ProductImage(product: product))),
          const SizedBox(height: 6),
          Text(product.name, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11)),
          Text(PriceFormatter.format(product.price),
            style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
        ])));
  }
}

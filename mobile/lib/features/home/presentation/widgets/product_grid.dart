import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

/// Infinite scroll product grid for the home page.
/// Loads more products when user scrolls near the bottom.
class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool hasMore;
  final bool loadingMore;
  final ValueChanged<ProductModel> onProductTap;

  /// Creates the ProductGrid widget.
  const ProductGrid({
    super.key,
    required this.products,
    required this.hasMore,
    required this.loadingMore,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75,
          crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          onTap: () => onProductTap(products[i]))),
      if (loadingMore)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2))),
      if (!hasMore && products.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('—',
            style: TextStyle(color: Colors.grey.shade400)))),
    ]);
  }
}

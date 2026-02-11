import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../data/models/product_model.dart';
import '../widgets/hero_banner.dart';
import '../widgets/special_section.dart';
import '../widgets/product_grid.dart';

/// Builds the scrollable content body for the home page.
/// Contains: HeroBanner → SpecialSection → ProductGrid.
Widget buildHomeContent({
  required BuildContext context,
  required ScrollController scrollCtrl,
  required List<ProductModel> products,
  required bool hasMore,
  required bool loadingMore,
  required ValueChanged<ProductModel> onProductTap,
}) {
  final isVi = context.watch<AppProvider>()
      .locale.languageCode == 'vi';

  return SingleChildScrollView(
    controller: scrollCtrl,
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (products.isNotEmpty)
          HeroBanner(
            product: products.first,
            onBuyNow: () => onProductTap(products.first)),
        const SizedBox(height: 24),

        // Special section (placeholder for future recommendation)
        SpecialSection(
          products: products.take(5).toList(),
          onProductTap: onProductTap),
        const SizedBox(height: 24),

        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isVi ? 'Sản Phẩm' : 'All Products',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune,
                    color: Colors.white, size: 18)),
            ])),
        const SizedBox(height: 16),

        // Infinite scroll product grid
        ProductGrid(
          products: products,
          hasMore: hasMore,
          loadingMore: loadingMore,
          onProductTap: onProductTap),
        const SizedBox(height: 24),
      ]));
}

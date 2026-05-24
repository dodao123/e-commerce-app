import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../data/models/product_model.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/special_section.dart';
import '../widgets/product_card.dart';
import '../../../../core/theme/app_colors.dart';

/// Builds the scrollable content body for the home page.
/// Uses CustomScrollView + Slivers for efficient lazy rendering.
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

  return CustomScrollView(
    controller: scrollCtrl,
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      // Top spacing
      const SliverToBoxAdapter(child: SizedBox(height: 8)),

      // Hero Banner Carousel
      SliverToBoxAdapter(child: HeroBannerCarousel(
        onProductTap: onProductTap)),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // Special section
      SliverToBoxAdapter(child: SpecialSection(
        products: products.take(5).toList(),
        onProductTap: onProductTap)),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // Section header
      SliverToBoxAdapter(child: Padding(
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
          ]))),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Lazy product grid — only renders visible items
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14),
          delegate: SliverChildBuilderDelegate(
            (_, i) => ProductCard(
              product: products[i],
              onTap: () => onProductTap(products[i])),
            childCount: products.length))),

      // Loading indicator
      if (loadingMore)
        const SliverToBoxAdapter(child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2)))),

      // End marker
      if (!hasMore && products.isNotEmpty)
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('—',
            style: TextStyle(color: Colors.grey.shade400))))),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]);
}

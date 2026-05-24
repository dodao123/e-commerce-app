import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../data/models/product_model.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/special_section.dart';
import '../widgets/product_card.dart';
import '../../../../core/theme/app_colors.dart';

/// Builds the scrollable content body for the home page.
Widget buildHomeContent({
  required BuildContext context,
  required ScrollController scrollCtrl,
  required List<ProductModel> products,
  required bool hasMore,
  required bool loadingMore,
  required String selectedCategory,
  required ValueChanged<String> onCategorySelected,
  required ValueChanged<ProductModel> onProductTap,
}) {
  final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

  return CustomScrollView(
    controller: scrollCtrl,
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverToBoxAdapter(child: HeroBannerCarousel(onProductTap: onProductTap)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverToBoxAdapter(child: SpecialSection(products: products.take(5).toList(), onProductTap: onProductTap)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isVi ? 'Sản Phẩm' : 'All Products', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            PopupMenuButton<String>(
              initialValue: selectedCategory,
              onSelected: onCategorySelected,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedCategory.isNotEmpty ? AppColors.primary : Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 18),
              ),
              itemBuilder: (context) {
                final categories = [
                  {'id': '', 'en': 'All Products', 'vi': 'Tất cả sản phẩm'},
                  {'id': 'electronics', 'en': 'Electronics', 'vi': 'Điện tử'},
                  {'id': 'fashion', 'en': 'Fashion', 'vi': 'Thời trang'},
                  {'id': 'beauty', 'en': 'Beauty', 'vi': 'Mỹ phẩm & Làm đẹp'},
                  {'id': 'food', 'en': 'Food & Drinks', 'vi': 'Ẩm thực'},
                  {'id': 'sports', 'en': 'Sports', 'vi': 'Thể thao'},
                  {'id': 'home', 'en': 'Home & Living', 'vi': 'Nhà cửa & Đời sống'},
                ];
                return categories.map((cat) => PopupMenuItem<String>(
                  value: cat['id'],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isVi ? cat['vi']! : cat['en']!),
                      if (selectedCategory == cat['id'])
                        const Icon(Icons.check, color: AppColors.primary, size: 18),
                    ],
                  ),
                )).toList();
              },
            ),
          ],
        ),
      )),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => ProductCard(product: products[i], onTap: () => onProductTap(products[i])),
            childCount: products.length,
          ),
        ),
      ),
      if (loadingMore)
        const SliverToBoxAdapter(child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        )),
      if (!hasMore && products.isNotEmpty)
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('—', style: TextStyle(color: Colors.grey.shade400))),
        )),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );
}

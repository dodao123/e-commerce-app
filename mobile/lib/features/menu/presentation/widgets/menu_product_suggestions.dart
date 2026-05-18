import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../home/data/datasources/product_local_datasource.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/pages/product_detail_page.dart';

/// Product suggestions grid shown at the bottom of the Menu page.
/// "Có thể bạn cũng thích" / "You may also like"
class MenuProductSuggestions extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the MenuProductSuggestions widget.
  const MenuProductSuggestions({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final products = ProductLocalDatasource.getMockProducts().take(4).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = isVi ? 'vi' : 'en';

    return Column(children: [
      // Section divider with title
      Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(isVi ? 'Có thể bạn cũng thích' : 'You may also like',
              style: IndieFolkTheme.body(isDark).copyWith(fontSize: 13, fontWeight: FontWeight.w500,
                  color: IndieFolkTheme.secondary(isDark)))),
        const Expanded(child: Divider()),
      ]),
      const SizedBox(height: 14),
      // Product grid
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.72,
          crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: products.length,
        itemBuilder: (ctx, i) => _ProductSuggestionCard(
            product: products[i], lang: lang)),
    ]);
  }
}

/// Individual product suggestion card.
class _ProductSuggestionCard extends StatelessWidget {
  final ProductModel product;
  final String lang;

  const _ProductSuggestionCard({
    required this.product, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: IndieFolkTheme.surface(isDark),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6)),
              child: AspectRatio(aspectRatio: 1,
                child: Image.asset(product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 40))))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.localizedName(lang),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: IndieFolkTheme.body(isDark).copyWith(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('\$${product.price.toStringAsFixed(0)}',
                      style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 14,
                          color: IndieFolkTheme.tertiary(isDark),
                          fontWeight: FontWeight.bold)),
                ])),
          ]),
      ),
    );
  }
}

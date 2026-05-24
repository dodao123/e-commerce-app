import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/pages/product_detail_page.dart';
import '../../../home/presentation/widgets/product_card.dart';

/// Renders a 2-column grid of search results.
class SearchProductGrid extends StatelessWidget {
  /// The list of products returned from search.
  final List<ProductModel> products;

  /// Whether to use shrinkWrap mode (inside CustomScrollView).
  final bool shrinkWrap;

  /// Creates a search product grid widget.
  const SearchProductGrid({
    super.key,
    required this.products,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : null,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ProductCard(
          product: p,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: p),
          )),
        );
      },
    );
  }
}

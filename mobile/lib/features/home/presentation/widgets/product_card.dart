import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

/// Individual product card in the grid layout.
class ProductCard extends StatelessWidget {
  /// Product data to display.
  final ProductModel product;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a ProductCard for the given product.
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported, size: 50)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.localizedName(lang),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  _buildPriceRow(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('\$ ${product.price.toInt()}',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15,
                color: isDark
                    ? DarkColors.textPrimary
                    : AppColors.textPrimary)),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: isDark ? DarkColors.addButton : AppColors.addButton,
              shape: BoxShape.circle),
          child: Icon(Icons.add,
              color: isDark ? DarkColors.surface : Colors.white, size: 16),
        ),
      ],
    );
  }
}

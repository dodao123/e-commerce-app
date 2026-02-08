import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

/// "Special for you" horizontal list section.
class SpecialSection extends StatelessWidget {
  /// Products to display in the special section.
  final List<ProductModel> products;

  /// Callback when a product is tapped.
  final ValueChanged<ProductModel>? onProductTap;

  /// Creates SpecialSection with the given products.
  const SpecialSection({super.key, required this.products, this.onProductTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return Column(
      children: [
        _buildHeader(isDark, lang),
        const SizedBox(height: 14),
        ...products.map((p) => _buildItem(p, isDark, lang)),
      ],
    );
  }

  Widget _buildHeader(bool isDark, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lang == 'vi' ? 'Dành riêng cho bạn' : 'Special for you',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(lang == 'vi' ? 'Xem tất cả' : 'See All',
              style: TextStyle(fontSize: 14, color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildItem(ProductModel product, bool isDark, String lang) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark
              ? DarkColors.darkCardGradient
              : AppColors.darkCardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50, height: 50,
              child: Image.asset(product.imageUrl, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.devices,
                      size: 40,
                      color: isDark ? Colors.white54 : Colors.black54)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.localizedName(lang),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$ ${product.price.toInt()}',
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

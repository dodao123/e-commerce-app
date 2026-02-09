import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

/// Dark hero banner card with product image floating outside the box.
class HeroBanner extends StatelessWidget {
  /// The featured product to display.
  final ProductModel product;

  /// Callback when "Buy Now" is tapped.
  final VoidCallback? onBuyNow;

  /// Creates a HeroBanner with the given product.
  const HeroBanner({super.key, required this.product, this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 160, right: 20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? DarkColors.darkCardGradient
                  : AppColors.darkCardGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNewLabel(isDark, lang),
                const SizedBox(height: 6),
                Text(product.localizedName(lang),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildBuyButton(lang),
              ],
            ),
          ),
          Positioned(
            left: -30, top: -45, bottom: 0, width: 220,
            child: Image.asset(product.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.headphones,
                    size: 100, color: isDark ? Colors.white54 : Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildNewLabel(bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(lang == 'vi' ? 'Sản Phẩm Mới' : 'New Product',
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87, fontSize: 11)),
    );
  }

  Widget _buildBuyButton(String lang) {
    return GestureDetector(
      onTap: onBuyNow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(lang == 'vi' ? 'Mua Ngay!' : 'Buy Now!',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import 'hero_banner_elements.dart';

/// Dark hero banner card with product image floating outside the box.
class HeroBanner extends StatelessWidget {
  /// The featured product to display.
  final ProductModel product;

  /// Callback when "Buy Now" is tapped.
  final VoidCallback? onBuyNow;

  /// Creates a HeroBanner with the given product.
  const HeroBanner({
    super.key, required this.product, this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 35),
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 190, right: 15),
            decoration: BoxDecoration(
              gradient: isDark ? DarkColors.darkCardGradient : AppColors.darkCardGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildNewLabel(isDark, lang),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(product.localizedName(lang),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                buildBuyButton(lang, product, (_) => onBuyNow?.call()),
              ],
            ),
          ),
          Positioned(
            left: 15, top: -35, bottom: 0, width: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GlowingAura(isDark: isDark),
                ProductImage(
                  product: product,
                  errorWidget: Icon(Icons.headphones,
                      size: 100,
                      color: isDark ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

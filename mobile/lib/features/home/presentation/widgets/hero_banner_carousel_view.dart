import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import 'buy_now_button.dart';
import 'glowing_aura.dart';
import 'new_product_ribbon.dart';

/// Presentation for product in hero banner carousel.
class HeroBannerCarouselView extends StatelessWidget {
  /// The product to display.
  final ProductModel product;

  /// Callback when the product is tapped.
  final ValueChanged<ProductModel> onProductTap;

  /// Creates a HeroBannerCarouselView.
  const HeroBannerCarouselView({
    super.key,
    required this.product,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final textStyle = TextStyle(
      color: isDark ? DarkColors.textPrimary : AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.3,
    );

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 35),
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 208, right: 12),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? DarkColors.darkCardGradient
                        : AppColors.darkCardGradient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            product.localizedName(lang),
                            key: ValueKey<String>(product.id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BuyNowButton(product: product, onTap: onProductTap),
                    ],
                  ),
                ),
                const NewProductRibbon(),
              ],
            ),
          ),
          Positioned(
            left: -10,
            top: -45,
            bottom: 4,
            width: 208,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GlowingAura(isDark: isDark),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    key: ValueKey<String>(product.imageUrl),
                    width: 208,
                    child: ProductImage(
                      product: product,
                      errorWidget: Icon(
                        Icons.headphones,
                        size: 100,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

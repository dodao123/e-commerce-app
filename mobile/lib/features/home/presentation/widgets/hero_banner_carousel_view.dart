import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import 'buy_now_button.dart';
import 'glowing_aura.dart';
import 'new_product_ribbon.dart';

/// Presentation for product in hero banner carousel.
class HeroBannerCarouselView extends StatelessWidget {
  final ProductModel product;
  final ValueChanged<ProductModel> onProductTap;

  const HeroBannerCarouselView(
      {super.key, required this.product, required this.onProductTap});

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.purple.withOpacity(0.12)
                : AppColors.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 195, right: 10),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? DarkColors.darkCardGradient
                        : AppColors.darkCardGradient,
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.04),
                        width: 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          layoutBuilder: (curr, prev) => Stack(
                              alignment: Alignment.centerLeft,
                              children: [...prev, if (curr != null) curr]),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.25),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: anim, curve: Curves.easeOut)),
                              child: child,
                            ),
                          ),
                          child: Text(product.localizedName(lang),
                              key: ValueKey<String>(product.id),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle),
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
            left: -50,
            top: -30,
            bottom: 4,
            width: 288,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GlowingAura(isDark: isDark),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  layoutBuilder: (curr, prev) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [...prev, if (curr != null) curr]),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                          CurvedAnimation(
                              parent: anim, curve: Curves.easeOutBack)),
                      child: child,
                    ),
                  ),
                  child: SizedBox(
                    key: ValueKey<String>(product.imageUrl),
                    width: 268,
                    height: 200,
                    child: ProductImage(
                        product: product,
                        errorWidget: Icon(Icons.headphones,
                            size: 100,
                            color: isDark ? Colors.white54 : Colors.black54)),
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

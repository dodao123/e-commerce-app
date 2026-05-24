import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import 'buy_now_button.dart';
import 'glowing_aura.dart';
import 'new_product_ribbon.dart';

/// Dark hero banner card with product image floating outside the box.
class HeroBanner extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onBuyNow;

  const HeroBanner({super.key, required this.product, this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;
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
                        child: Text(
                          product.localizedName(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BuyNowButton(
                          product: product, onTap: (_) => onBuyNow?.call()),
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
                SizedBox(
                  width: 268,
                  height: 200,
                  child: ProductImage(
                      product: product,
                      errorWidget: Icon(Icons.headphones,
                          size: 100,
                          color: isDark ? Colors.white54 : Colors.black54)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

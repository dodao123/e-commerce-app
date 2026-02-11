import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/animation/fly_to_cart_animator.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_icon_key_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';

/// Individual product card in the grid layout.
class ProductCard extends StatelessWidget {
  /// Product data to display.
  final ProductModel product;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a ProductCard for the given product.
  const ProductCard({
    super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Center(child: Padding(
              padding: const EdgeInsets.all(12),
              child: ProductImage(product: product)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.localizedName(lang),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  _PriceRow(product: product, isDark: isDark),
                ])),
          ]),
      ),
    );
  }
}

/// Price row with fly-to-cart cart button.
class _PriceRow extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const _PriceRow({required this.product, required this.isDark});

  void _handleAddToCart(BuildContext context, GlobalKey btnKey) {
    final cartKey =
        context.read<CartIconKeyProvider>().cartIconKey;
    final cartBox = cartKey.currentContext?.findRenderObject()
        as RenderBox?;
    final btnBox = btnKey.currentContext?.findRenderObject()
        as RenderBox?;
    if (cartBox == null || btnBox == null) return;

    final start = btnBox.localToGlobal(Offset.zero);
    final end = cartBox.localToGlobal(Offset(
        cartBox.size.width / 2 - 12.5,
        cartBox.size.height / 2 - 12.5));

    FlyToCartOverlay.fly(context,
        start: start, end: end,
        imageAsset: product.imageUrl,
        isNetwork: product.isNetworkImage);
  }

  @override
  Widget build(BuildContext context) {
    final btnKey = GlobalKey();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(PriceFormatter.format(product.price),
            style: TextStyle(fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark
                    ? DarkColors.textPrimary
                    : AppColors.textPrimary)),
        GestureDetector(
          key: btnKey,
          onTap: () => _handleAddToCart(context, btnKey),
          child: Container(width: 28, height: 28,
            decoration: BoxDecoration(
                color: isDark
                    ? DarkColors.addButton : AppColors.addButton,
                shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined,
                color: isDark
                    ? DarkColors.surface : Colors.white,
                size: 14))),
      ]);
  }
}

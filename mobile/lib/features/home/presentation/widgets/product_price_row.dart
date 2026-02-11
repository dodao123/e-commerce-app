import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/animation/fly_to_cart_animator.dart';
import '../../../../core/providers/cart_icon_key_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/product_model.dart';

/// Price row with fly-to-cart animation button.
class ProductPriceRow extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  /// Creates the ProductPriceRow widget.
  const ProductPriceRow({
    super.key, required this.product, required this.isDark});

  void _handleAddToCart(BuildContext ctx, GlobalKey key) {
    final cartKey =
        ctx.read<CartIconKeyProvider>().cartIconKey;
    final cartBox = cartKey.currentContext?.findRenderObject()
        as RenderBox?;
    final btnBox = key.currentContext?.findRenderObject()
        as RenderBox?;
    if (cartBox == null || btnBox == null) return;
    final start = btnBox.localToGlobal(Offset.zero);
    final end = cartBox.localToGlobal(Offset(
        cartBox.size.width / 2 - 12.5,
        cartBox.size.height / 2 - 12.5));
    FlyToCartOverlay.fly(ctx, start: start, end: end,
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
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
            color: isDark
                ? DarkColors.textPrimary : AppColors.textPrimary)),
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

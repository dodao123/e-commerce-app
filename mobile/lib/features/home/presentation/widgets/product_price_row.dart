import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/animation/fly_to_cart_animator.dart';
import '../../../../core/providers/cart_icon_key_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/role_guard.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../data/models/product_model.dart';

/// Price row with fly-to-cart and buy-now buttons.
class ProductPriceRow extends StatelessWidget {
  /// Product to display.
  final ProductModel product;

  /// Whether the theme is dark.
  final bool isDark;

  /// Creates the ProductPriceRow widget.
  const ProductPriceRow({
    super.key, required this.product, required this.isDark});

  void _handleAddToCart(BuildContext ctx, GlobalKey key) {
    if (!RoleGuard.checkBuyerRole(ctx)) return;
    final cartKey =
        ctx.read<CartIconKeyProvider>().cartIconKey;
    final cartBox = cartKey.currentContext
        ?.findRenderObject() as RenderBox?;
    final btnBox = key.currentContext
        ?.findRenderObject() as RenderBox?;
    if (cartBox == null || btnBox == null) return;
    final start = btnBox.localToGlobal(Offset.zero);
    final end = cartBox.localToGlobal(Offset(
        cartBox.size.width / 2 - 12.5,
        cartBox.size.height / 2 - 12.5));
    FlyToCartOverlay.fly(ctx, start: start, end: end,
        imageAsset: product.imageUrl,
        isNetwork: product.isNetworkImage);
    ctx.read<CartProvider>().addToCart(product.id, 1);
  }

  void _handleBuyNow(BuildContext ctx) {
    if (!RoleGuard.checkBuyerRole(ctx)) return;
    Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => CheckoutPage(items: [{
          'product_id': product.id,
          'product_name': product.name,
          'product_image': product.imageUrl,
          'price': product.price,
          'quantity': 1,
          'shop_id': product.shopId,
          'shop_name': product.shopName,
          'shipping_fee': product.baseShippingFee,
        }])));
  }

  @override
  Widget build(BuildContext context) {
    final btnKey = GlobalKey();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(
            PriceFormatter.format(product.price),
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15,
                color: isDark
                    ? DarkColors.textPrimary
                    : AppColors.textPrimary))),
        Transform.translate(
          offset: const Offset(-5, 0),
          child: GestureDetector(
            onTap: () => _handleBuyNow(context),
            child: Container(width: 34, height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFEF6C4A),
                shape: BoxShape.circle),
              child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white, size: 18)))),
        GestureDetector(
          key: btnKey,
          onTap: () => _handleAddToCart(context, btnKey),
          child: Container(width: 34, height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? DarkColors.addButton
                  : AppColors.addButton,
              shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined,
                color: isDark
                    ? DarkColors.surface : Colors.white,
                size: 18))),
      ]);
  }
}

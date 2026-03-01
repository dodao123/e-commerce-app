import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/role_guard.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../data/models/product_model.dart';
import '../widgets/detail_image_carousel.dart';

/// Builds the image header for the product detail page.
Widget buildDetailImageHeader({
  required BuildContext context,
  required ProductModel product,
  required PageController pageCtrl,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
  required bool isDark,
}) {
  final images = product.imageDetail.isNotEmpty
      ? product.imageDetail : [product.imageUrl];
  return Container(
    height: MediaQuery.of(context).size.height * 0.4,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: isDark
          ? DarkColors.darkCardGradient
          : AppColors.darkCardGradient,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30))),
    child: SafeArea(child: Stack(children: [
      _navButton(Icons.arrow_back, Alignment.topLeft, isDark,
          () => Navigator.pop(context)),
      _navButton(Icons.bookmark_border, Alignment.topRight,
          isDark, () {}),
      DetailImageCarousel(
        images: images, pageController: pageCtrl,
        currentPage: currentPage,
        onPageChanged: onPageChanged, isDark: isDark),
    ])));
}

Widget _navButton(
    IconData icon, Alignment align, bool isDark, VoidCallback onTap) {
  final isLeft = align == Alignment.topLeft;
  return Positioned(
    top: 8, left: isLeft ? 16 : null, right: isLeft ? null : 16,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: isDark ? Colors.white : Colors.black87)));
}

/// Builds bottom bar with add-to-cart and buy-now buttons.
Widget buildDetailCartButton(
    BuildContext context, String lang, ProductModel product) {
  final isVi = context.read<AppProvider>()
      .locale.languageCode == 'vi';
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
    child: Row(children: [
      Expanded(child: ElevatedButton(
        onPressed: () async {
          if (!RoleGuard.checkBuyerRole(context)) return;
          final cart = context.read<CartProvider>();
          final ok = await cart.addToCart(product.id, 1);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? (isVi ? 'Đã thêm vào giỏ hàng'
                    : 'Added to cart')
                : (isVi ? 'Không thể thêm vào giỏ'
                    : 'Failed to add to cart')),
            backgroundColor: ok ? AppColors.primary : Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                  color: AppColors.primary)),
          elevation: 0),
        child: Text(isVi ? 'Thêm vào giỏ' : 'Add to cart',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)))),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton(
        onPressed: () {
          if (!RoleGuard.checkBuyerRole(context)) return;
          Navigator.push(context, MaterialPageRoute(
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          elevation: 0),
        child: Text(isVi ? 'Mua ngay' : 'Buy now',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)))),
    ]));
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/role_guard.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../data/models/product_model.dart';
import '../widgets/detail_image_carousel.dart';
import '../widgets/product_option_sheet.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../auth/providers/auth_provider.dart';

/// Builds the image header for the product detail page.
Widget buildDetailImageHeader({
  required BuildContext context,
  required ProductModel product,
  required PageController pageCtrl,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
  required bool isDark,
}) {
  final images =
      product.imageDetail.isNotEmpty ? product.imageDetail : [product.imageUrl];
  return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient:
              isDark ? DarkColors.darkCardGradient : AppColors.darkCardGradient,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      child: SafeArea(
          child: Stack(children: [
        _navButton(Icons.arrow_back, Alignment.topLeft, isDark,
            () => Navigator.pop(context)),
        Positioned(
          top: 8,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () async {
                    if (!RoleGuard.checkBuyerRole(context)) return;
                    final auth = context.read<AuthProvider>();
                    final token = auth.accessToken;
                    if (token == null) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final room = await ChatRemoteDatasource().getOrCreateRoom(
                        token: token,
                        roomType: 'customer_shop',
                        shopId: product.shopId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context); // Close progress dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(
                              roomId: room.id,
                              partnerName: product.shopName,
                              partnerAvatar: room.partnerAvatar.isNotEmpty
                                  ? room.partnerAvatar
                                  : 'https://api.dicebear.com/7.x/adventurer/svg?seed=${product.shopId}',
                            ),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close progress dialog
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Không thể kết nối trò chuyện lúc này'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    }
                  },
                  icon: Transform.translate(
                    offset: const Offset(0, 1.5),
                    child: Icon(Icons.chat_bubble_outline,
                        color: isDark ? Colors.white : Colors.black87),
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.bookmark_border,
                      color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
        DetailImageCarousel(
            images: images,
            pageController: pageCtrl,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
            isDark: isDark),
      ])));
}

Widget _navButton(
    IconData icon, Alignment align, bool isDark, VoidCallback onTap) {
  final isLeft = align == Alignment.topLeft;
  return Positioned(
      top: 8,
      left: isLeft ? 16 : null,
      right: isLeft ? null : 16,
      child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: isDark ? Colors.white : Colors.black87)));
}

/// Builds bottom bar with add-to-cart and buy-now buttons.
/// Shows option sheet first if the product has options.
Widget buildDetailCartButton(
    BuildContext context, String lang, ProductModel product) {
  final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
  return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () => _handleAddToCart(context, product, isVi),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: AppColors.primary)),
                    elevation: 0),
                child: Text(isVi ? 'Thêm vào giỏ' : 'Add to cart',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)))),
        const SizedBox(width: 12),
        Expanded(
            child: ElevatedButton(
                onPressed: () => _handleBuyNow(context, product, isVi),
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

/// Handles add-to-cart with optional option selection.
Future<void> _handleAddToCart(
    BuildContext ctx, ProductModel product, bool isVi) async {
  if (!RoleGuard.checkBuyerRole(ctx)) return;

  if (product.hasOptions) {
    final result = await showProductOptionSheet(ctx, product);
    if (result == null) return;
  }

  if (!ctx.mounted) return;
  final cart = ctx.read<CartProvider>();
  final ok = await cart.addToCart(product.id, 1);
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(ok
        ? (isVi ? 'Đã thêm vào giỏ hàng' : 'Added to cart')
        : (isVi ? 'Không thể thêm vào giỏ' : 'Failed to add to cart')),
    backgroundColor: ok ? AppColors.primary : Colors.red,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

/// Handles buy-now with optional option selection.
Future<void> _handleBuyNow(
    BuildContext ctx, ProductModel product, bool isVi) async {
  if (!RoleGuard.checkBuyerRole(ctx)) return;

  int quantity = 1;
  String optionLabel = '';

  if (product.hasOptions) {
    final result = await showProductOptionSheet(ctx, product);
    if (result == null) return;
    quantity = int.tryParse(result['_quantity'] ?? '1') ?? 1;
    final opts = Map<String, String>.from(result)..remove('_quantity');
    optionLabel = opts.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  if (!ctx.mounted) return;
  Navigator.push(
      ctx,
      MaterialPageRoute(
          builder: (_) => CheckoutPage(items: [
                {
                  'product_id': product.id,
                  'product_name': product.name,
                  'product_image': product.imageUrl,
                  'price': product.price,
                  'quantity': quantity,
                  'shop_id': product.shopId,
                  'shop_name': product.shopName,
                  'shipping_fee': product.baseShippingFee,
                  if (optionLabel.isNotEmpty) 'selected_options': optionLabel,
                }
              ])));
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../../shop/presentation/pages/shop_detail_page.dart';

/// Shop info banner displayed on the product detail page.
/// Shows shop name, location, and a "View Shop" button.
class DetailShopBanner extends StatelessWidget {
  final ProductModel product;

  /// Creates the DetailShopBanner widget.
  const DetailShopBanner({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.shopName.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: Row(children: [
        _shopIcon(isDark),
        const SizedBox(width: 12),
        Expanded(child: _shopInfo(isDark)),
        _viewShopButton(context, isVi),
      ]));
  }

  Widget _shopIcon(bool isDark) {
    if (product.shopAvatar.isNotEmpty) {
      return CircleAvatar(radius: 22,
        backgroundImage: NetworkImage(product.shopAvatar),
        onBackgroundImageError: (_, __) {},
        backgroundColor:
            AppColors.primary.withValues(alpha: 0.1));
    }
    return Container(width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22)),
      child: Icon(Icons.storefront,
          color: AppColors.primary, size: 22));
  }

  Widget _shopInfo(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(product.shopName,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 1, overflow: TextOverflow.ellipsis),
      if (product.shopProvince.isNotEmpty)
        Text(product.shopProvince,
          style: TextStyle(fontSize: 12,
            color: isDark ? DarkColors.textSecondary
                : Colors.grey.shade600)),
    ]);

  Widget _viewShopButton(BuildContext context, bool isVi) => OutlinedButton(
    onPressed: () {
      if (product.shopId.isNotEmpty) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ShopDetailPage(shopId: product.shopId),
        ));
      }
    },
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    child: Text(isVi ? 'Xem Shop' : 'View Shop', style: TextStyle(
        color: AppColors.primary, fontSize: 12)));
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Products section widget for checkout page.
class CheckoutProductsSection extends StatelessWidget {
  /// Cart items to display.
  final List<Map<String, dynamic>> items;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates CheckoutProductsSection.
  const CheckoutProductsSection({
    super.key,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items.isNotEmpty &&
                (items.first['shop_name'] ?? '')
                    .toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const Icon(Icons.store_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(items.first['shop_name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ])),
            ...items.map(_productRow),
          ])));
  }

  Widget _productRow(Map<String, dynamic> item) {
    final imgUrl = ApiConstants.resolveImageUrl(
        item['product_image']?.toString() ?? '');
    final price = (item['price'] as num).toDouble();
    final qty = (item['quantity'] as num).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: imgUrl.startsWith('http')
                ? Image.network(imgUrl,
                    width: 72, height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _imgPlaceholder())
                : _imgPlaceholder()),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['product_name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text('${PriceFormatter.formatFull(price)}đ',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ])),
          Text('x$qty', style: TextStyle(fontSize: 13,
              color: Colors.grey.shade500)),
        ]));
  }

  Widget _imgPlaceholder() => Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6)),
      child: const Icon(Icons.image_outlined,
          color: Colors.grey));
}

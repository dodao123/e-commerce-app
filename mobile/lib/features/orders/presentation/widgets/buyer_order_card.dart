import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/utils/price_formatter.dart';

/// Single order card widget for buyer order list.
class BuyerOrderCard extends StatelessWidget {
  /// Order data map.
  final Map<String, dynamic> order;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Called when cancel button is pressed.
  final VoidCallback? onCancel;

  /// Creates BuyerOrderCard.
  const BuyerOrderCard({
    super.key,
    required this.order,
    required this.isDark,
    required this.isVi,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final total = (order['total'] ?? 0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_statusBadge(status)]),
          const SizedBox(height: 12),
          if (order['items'] != null
              && (order['items'] as List).isNotEmpty) ...[
            _itemPreview(order['items'] as List),
            const SizedBox(height: 12),
          ],
          Row(children: [
            Icon(Icons.payments_outlined, size: 16,
                color: IndieFolkTheme.tertiary(isDark)),
            const SizedBox(width: 6),
            Text('${PriceFormatter.formatFull(total)}đ',
                style: IndieFolkTheme.h1(isDark).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: IndieFolkTheme.tertiary(
                        isDark))),
            const Spacer(),
            if (status == 'pending' && onCancel != null)
              _cancelBtn(),
          ])]));
  }

  Widget _itemPreview(List items) {
    final first = items.first;
    final name = first['product_name'] ?? '';
    final shopName = first['shop_name'] ?? '';
    final qty = first['quantity'] ?? 1;
    final image = ApiConstants.resolveImageUrl(
        first['product_image'] ?? '');
    final extra =
        items.length > 1 ? (items.length - 1) : 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: image.isNotEmpty
              ? Image.network(image,
                  width: 50, height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _imgPlaceholder())
              : _imgPlaceholder()),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(name, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: IndieFolkTheme.body(isDark)
                    .copyWith(fontSize: 13,
                        fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(isVi ? 'Từ shop: $shopName'
                : 'From shop: $shopName',
                style: IndieFolkTheme.body(isDark)
                    .copyWith(fontSize: 11,
                        color: IndieFolkTheme
                            .secondary(isDark))),
            if (extra > 0)
              Text(isVi
                  ? '...và $extra sản phẩm khác'
                  : '...and $extra more items',
                  style: IndieFolkTheme.body(isDark)
                      .copyWith(fontSize: 11,
                          color: IndieFolkTheme
                              .tertiary(isDark))),
          ])),
        const SizedBox(width: 8),
        Text('x$qty',
            style: IndieFolkTheme.body(isDark)
                .copyWith(fontSize: 13)),
      ]);
  }

  Widget _cancelBtn() {
    return SizedBox(height: 30,
      child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(
              horizontal: 12),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(6))),
        child: Text(isVi ? 'Hủy đơn' : 'Cancel',
            style: IndieFolkTheme.body(isDark)
                .copyWith(fontSize: 12))));
  }

  Widget _statusBadge(String status) {
    final labels = {
      'pending': isVi ? 'Chờ xác nhận' : 'Pending',
      'finding_driver': isVi
          ? 'Chờ Shipper' : 'Finding Shipper',
      'shipping': isVi ? 'Đang giao' : 'Shipping',
      'delivered': isVi ? 'Đã giao' : 'Delivered',
      'cancelled': isVi ? 'Đã hủy' : 'Cancelled',
    };
    final colors = {
      'pending': Colors.orange,
      'finding_driver': Colors.purple,
      'shipping': Colors.blue,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20)),
      child: Text(labels[status] ?? status,
          style: IndieFolkTheme.body(isDark).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors[status] ?? Colors.grey)));
  }

  Widget _imgPlaceholder() {
    return Container(width: 50, height: 50,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 24,
            color: Colors.grey));
  }
}

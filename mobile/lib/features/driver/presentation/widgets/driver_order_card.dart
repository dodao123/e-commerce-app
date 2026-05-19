import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Single order card used in the driver order list.
class DriverOrderCard extends StatelessWidget {
  /// Order data map.
  final Map<String, dynamic> order;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Creates DriverOrderCard.
  const DriverOrderCard({
    super.key,
    required this.order,
    required this.isDark,
    required this.isVi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final first = items.first;
    final name = first['product_name'] ?? '';
    final qty = first['quantity'] ?? 1;
    final image = ApiConstants.resolveImageUrl(
        first['product_image'] ?? '');
    final extra =
        items.length > 1 ? (items.length - 1) : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isDark
            ? DarkColors.surface : Colors.white,
        child: Column(children: [
          _header(status),
          const Divider(height: 1),
          _itemPreview(name, qty, image),
          if (extra > 0) _extraLabel(extra),
          const Divider(height: 1),
          _footer(),
        ])));
  }

  Widget _header(String status) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Đơn: ${order['id'].toString().split('-').first.toUpperCase()}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white70 : Colors.black87,
              fontSize: 13)),
          _statusBadge(status),
        ]));
  }

  Widget _itemPreview(
      String name, int qty, String image) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: image.startsWith('http')
                ? Image.network(image,
                    width: 60, height: 60,
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
                  style: TextStyle(fontSize: 14,
                      color: isDark
                          ? Colors.white
                          : Colors.black87)),
              const SizedBox(height: 4),
              Text(isVi ? 'x$qty sản phẩm'
                  : 'x$qty items',
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey.shade500)),
            ])),
        ]));
  }

  Widget _extraLabel(int extra) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        isVi ? 'Xem thêm $extra sản phẩm'
            : 'View $extra more products',
        style: TextStyle(fontSize: 12,
            color: Colors.grey.shade500)));
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(isVi ? 'Tổng tiền thu hộ:'
              : 'COD amount:',
              style: TextStyle(fontSize: 13,
                  color: isDark
                      ? Colors.white70
                      : Colors.black87)),
          Text(
            '${PriceFormatter.formatFull((order['total'] as num).toDouble())}đ',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.primary)),
        ]));
  }

  Widget _statusBadge(String status) {
    final map = {
      'finding_driver': (Colors.blue,
          isVi ? 'Đang lấy' : 'Picking Up'),
      'shipping': (Colors.orange,
          isVi ? 'Đang giao' : 'Shipping'),
      'delivered': (Colors.green,
          isVi ? 'Đã giao' : 'Delivered'),
      'cancelled': (Colors.red,
          isVi ? 'Đã huỷ' : 'Cancelled'),
    };
    final entry = map[status];
    final c = entry?.$1 ?? Colors.grey;
    final text =
        entry?.$2 ?? status.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(
          color: c, fontSize: 12,
          fontWeight: FontWeight.w600)));
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 60, height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined,
          color: Colors.grey));
  }
}

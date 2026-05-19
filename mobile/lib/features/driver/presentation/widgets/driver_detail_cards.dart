import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Status card widget for driver order detail.
class DriverStatusCard extends StatelessWidget {
  /// Current order status.
  final String status;

  /// Whether the app is in Vietnamese mode.
  final bool isVi;

  /// Creates DriverStatusCard.
  const DriverStatusCard({
    super.key,
    required this.status,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final labels = {
      'finding_driver': isVi
          ? 'Chờ Shipper nhận' : 'Waiting for Pickup',
      'shipping': isVi ? 'Đang giao' : 'On the Way',
      'delivered': isVi
          ? 'Đã giao thành công' : 'Delivered',
      'cancelled': isVi ? 'Đã hủy' : 'Cancelled',
    };
    final colors = {
      'finding_driver': Colors.purple,
      'shipping': Colors.blue,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    final icons = {
      'finding_driver': Icons.person_search,
      'shipping': Icons.local_shipping,
      'delivered': Icons.check_circle,
      'cancelled': Icons.cancel,
    };
    final color = colors[status] ?? Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icons[status] ?? Icons.help,
            size: 32, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labels[status] ?? status,
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            if (status == 'finding_driver')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isVi ? 'Đơn này đang chờ tài xế nhận'
                      : 'This order is awaiting pickup',
                  style: TextStyle(fontSize: 12,
                      color: color.withOpacity(0.8)))),
          ])),
      ]));
  }
}

/// Delivery address card for driver order detail.
class DriverAddressCard extends StatelessWidget {
  /// Order data containing address fields.
  final Map<String, dynamic> order;

  /// Whether the app is in Vietnamese mode.
  final bool isVi;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates DriverAddressCard.
  const DriverAddressCard({
    super.key,
    required this.order,
    required this.isVi,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(isVi ? 'Địa chỉ giao hàng'
                : 'Delivery Address',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          _infoRow(Icons.person_outline,
              order['receiver_name'] ?? ''),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_outlined,
              order['receiver_phone'] ?? ''),
          const SizedBox(height: 6),
          _infoRow(Icons.map_outlined,
              order['receiver_addr'] ?? ''),
          if ((order['note'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.note_outlined, order['note']),
          ],
        ]));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16,
            color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13))),
      ]);
  }
}

/// Order items card for driver order detail.
class DriverItemsCard extends StatelessWidget {
  /// List of order items.
  final List items;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates DriverItemsCard.
  const DriverItemsCard({
    super.key,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text('${items.length} sản phẩm',
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          for (final item in items) _itemRow(item),
        ]));
  }

  Widget _itemRow(dynamic item) {
    final name = item['product_name'] ?? '';
    final qty = item['quantity'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
            Text('x$qty', style: TextStyle(fontSize: 12,
                color: Colors.grey.shade500)),
          ])),
        Text('${PriceFormatter.formatFull(price)}đ',
            style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      ]));
  }
}

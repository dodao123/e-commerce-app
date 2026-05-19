import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Status card for seller order detail.
class SellerStatusCard extends StatelessWidget {
  /// Current order status.
  final String status;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates SellerStatusCard.
  const SellerStatusCard({
    super.key,
    required this.status,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
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
    final icons = {
      'pending': Icons.schedule,
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
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icons[status] ?? Icons.help,
            size: 32, color: color),
        const SizedBox(width: 12),
        Text(labels[status] ?? status,
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ]));
  }
}

/// Buyer info card for seller order detail.
class SellerBuyerCard extends StatelessWidget {
  /// Order data with receiver fields.
  final Map<String, dynamic> order;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates SellerBuyerCard.
  const SellerBuyerCard({
    super.key,
    required this.order,
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
          _infoRow(Icons.person_outline,
              order['receiver_name'] ?? ''),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_outlined,
              order['receiver_phone'] ?? ''),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined,
              order['receiver_addr'] ?? ''),
          if ((order['note'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.note_outlined, order['note']),
          ],
        ]));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18,
            color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13))),
      ]);
  }
}

/// Order items card for seller order detail.
class SellerItemsCard extends StatelessWidget {
  /// List of order items.
  final List items;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates SellerItemsCard.
  const SellerItemsCard({
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
          for (final item in items) _itemRow(item),
        ]));
  }

  Widget _itemRow(dynamic item) {
    final name = item['product_name'] ?? '';
    final qty = item['quantity'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
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

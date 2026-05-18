import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../checkout/data/order_datasource.dart';

/// Order detail page specifically for Drivers.
/// Shows delivery address, order items, and action buttons
/// to accept or mark orders as delivered.
class DriverOrderDetailPage extends StatefulWidget {
  /// Order ID to fetch details for.
  final String orderId;

  const DriverOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  State<DriverOrderDetailPage> createState() =>
      _DriverOrderDetailPageState();
}

class _DriverOrderDetailPageState
    extends State<DriverOrderDetailPage> {
  final _ds = OrderDatasource();
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    _detail = await _ds.fetchDetail(widget.orderId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isVi ? 'Chi tiết đơn giao' : 'Delivery Detail',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? Center(
                  child: Text(
                    isVi ? 'Không tìm thấy đơn'
                        : 'Order not found',
                  ),
                )
              : _buildContent(isVi, isDark),
    );
  }

  Widget _buildContent(bool isVi, bool isDark) {
    final order =
        _detail!['order'] as Map<String, dynamic>;
    final items = (_detail!['items'] as List?) ?? [];
    final status = order['status'] ?? 'pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _statusCard(status, isVi, isDark),
        const SizedBox(height: 12),
        _deliveryAddressCard(order, isVi, isDark),
        const SizedBox(height: 12),
        _itemsCard(items, isDark),
        const SizedBox(height: 12),
        _summaryCard(order, isDark),
        const SizedBox(height: 24),
        _actionArea(status, order, isVi),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _statusCard(String status, bool isVi, bool isDark) {
    final labels = {
      'finding_driver': isVi ? 'Chờ Shipper nhận' : 'Waiting for Pickup',
      'shipping': isVi ? 'Đang giao' : 'On the Way',
      'delivered': isVi ? 'Đã giao thành công' : 'Delivered',
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
    final icon = icons[status] ?? Icons.help;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labels[status] ?? status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (status == 'finding_driver')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isVi ? 'Đơn này đang chờ tài xế nhận'
                        : 'This order is awaiting pickup',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _deliveryAddressCard(
      Map<String, dynamic> order, bool isVi, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              isVi ? 'Địa chỉ giao hàng'
                  : 'Delivery Address',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          _infoRow(
            Icons.person_outline,
            order['receiver_name'] ?? '',
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.phone_outlined,
            order['receiver_phone'] ?? '',
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.map_outlined,
            order['receiver_addr'] ?? '',
          ),
          if ((order['note'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.note_outlined, order['note']),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _itemsCard(List items, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text('${items.length} sản phẩm',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          for (final item in items) _itemRow(item),
        ],
      ),
    );
  }

  Widget _itemRow(dynamic item) {
    final name = item['product_name'] ?? '';
    final qty = item['quantity'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
              Text('x$qty',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500)),
            ],
          ),
        ),
        Text(
          '${PriceFormatter.formatFull(price)}đ',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary),
        ),
      ]),
    );
  }

  Widget _summaryCard(
      Map<String, dynamic> order, bool isDark) {
    final total = (order['total'] ?? 0).toDouble();
    final shipping =
        (order['shipping_fee'] ?? 0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        _summaryRow('Phí vận chuyển', shipping),
        const Divider(height: 16),
        _summaryRow('Tổng thu hộ (COD)', total,
            bold: true),
      ]),
    );
  }

  Widget _summaryRow(String label, double value,
      {bool bold = false}) {
    return Row(children: [
      Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w400)),
      const Spacer(),
      Text(
        '${PriceFormatter.formatFull(value)}đ',
        style: TextStyle(
            fontSize: 14,
            fontWeight:
                bold ? FontWeight.bold : FontWeight.w500,
            color: bold ? AppColors.primary : null),
      ),
    ]);
  }

  /// Action buttons based on order status.
  Widget _actionArea(
      String status,
      Map<String, dynamic> order,
      bool isVi) {
    if (status == 'finding_driver') {
      return _acceptButton(order, isVi);
    }
    if (status == 'shipping') {
      return _deliveredButton(order['id'], isVi);
    }
    return const SizedBox.shrink();
  }

  Widget _acceptButton(
      Map<String, dynamic> order, bool isVi) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _acting ? null : () => _acceptOrder(order),
        icon: _acting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white),
              )
            : const Icon(Icons.delivery_dining),
        label: Text(
          isVi ? 'Nhận Đơn Giao' : 'Accept & Deliver',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _deliveredButton(String orderId, bool isVi) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _acting
            ? null
            : () => _markDelivered(orderId),
        icon: _acting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          isVi ? 'Xác nhận đã giao' : 'Mark as Delivered',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _acceptOrder(
      Map<String, dynamic> order) async {
    setState(() => _acting = true);
    try {
      final profile =
          await TokenManager().getUserProfile();
      final driverName =
          profile['full_name'] ?? 'Tài xế';
      final driverPhone = profile['phone'] ?? '';

      final ok = await _ds.acceptDelivery(
        orderId: order['id'],
        driverName: driverName,
        driverPhone: driverPhone,
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Đã nhận đơn thành công!')),
        );
        _fetch(); // refresh page
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  '❌ Đơn đã được người khác nhận hoặc có lỗi')),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _markDelivered(String orderId) async {
    setState(() => _acting = true);
    try {
      final ok = await _ds.markDelivered(orderId);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('✅ Đã xác nhận giao hàng thành công!')),
        );
        _fetch();
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }
}

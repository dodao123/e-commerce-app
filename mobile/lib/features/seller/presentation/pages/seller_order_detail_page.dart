import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../checkout/data/order_datasource.dart';
import '../../data/shop_order_datasource.dart';

/// Seller order detail page — shows full order info,
/// items, timeline, and status action buttons.
class SellerOrderDetailPage extends StatefulWidget {
  /// Order ID to fetch details for.
  final String orderId;

  /// Creates SellerOrderDetailPage.
  const SellerOrderDetailPage({
    super.key, required this.orderId});

  @override
  State<SellerOrderDetailPage> createState() =>
      _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState
    extends State<SellerOrderDetailPage> {
  final _ds = OrderDatasource();
  final _shopDS = ShopOrderDatasource();
  Map<String, dynamic>? _detail;
  bool _loading = true;

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
          ? DarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(isVi ? 'Chi tiết đơn' : 'Order Detail'),
        backgroundColor: Colors.transparent, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? _emptyState(isVi)
              : _buildContent(isVi, isDark));
  }

  Widget _emptyState(bool isVi) {
    return Center(child: Text(
        isVi ? 'Không tìm thấy đơn' : 'Order not found'));
  }

  Widget _buildContent(bool isVi, bool isDark) {
    final order = _detail!['order'] as Map<String, dynamic>;
    final items = (_detail!['items'] as List?) ?? [];
    final status = order['status'] ?? 'pending';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _statusCard(status, isVi, isDark),
        const SizedBox(height: 12),
        _buyerCard(order, isDark),
        const SizedBox(height: 12),
        if (status != 'pending' && status != 'cancelled') ...[
          _shipperCard(order, status, isVi, isDark),
          const SizedBox(height: 12),
        ],
        _itemsCard(items, isDark),
        const SizedBox(height: 12),
        _summaryCard(order, isDark),
        const SizedBox(height: 20),
        _actionButtons(status, order, isVi),
      ]));
  }

  Widget _statusCard(
      String status, bool isVi, bool isDark) {
    final labels = {
      'pending': isVi ? 'Chờ xác nhận' : 'Pending',
      'finding_driver': isVi ? 'Chờ Shipper' : 'Finding Shipper',
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
        Icon(_statusIcon(status), size: 32, color: color),
        const SizedBox(width: 12),
        Text(labels[status] ?? status,
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ]));
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending': return Icons.schedule;
      case 'finding_driver': return Icons.person_search;
      case 'shipping': return Icons.local_shipping;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  Widget _buyerCard(
      Map<String, dynamic> order, bool isDark) {
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
            _infoRow(Icons.note_outlined,
                order['note']),
          ],
        ]));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13))),
      ]);
  }

  Widget _shipperCard(
      Map<String, dynamic> order, String status, bool isVi, bool isDark) {
    if (status == 'finding_driver') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.person_search, color: Colors.purple.shade300, size: 24),
            const SizedBox(width: 12),
            Text(isVi ? 'Đang chờ Shipper nhận đơn...' : 'Waiting for shipper...',
                style: TextStyle(fontSize: 14, color: Colors.purple.shade300, fontWeight: FontWeight.w500)),
          ]));
    }

    final shipperName = order['shipper_name'] ?? (isVi ? 'Không rõ' : 'Unknown');
    final shipperPhone = order['shipper_phone'] ?? '';
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
            Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(isVi ? 'Thông tin Shipper' : 'Shipper Info',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          _infoRow(Icons.badge_outlined, shipperName),
          if (shipperPhone.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined, shipperPhone),
          ],
        ]));
  }

  Widget _itemsCard(List items, bool isDark) {
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

  Widget _summaryCard(
      Map<String, dynamic> order, bool isDark) {
    final subtotal = (order['subtotal'] ?? 0).toDouble();
    final shipping = (order['shipping_fee'] ?? 0).toDouble();
    final total = (order['total'] ?? 0).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _summaryRow('Tạm tính', subtotal),
        const SizedBox(height: 6),
        _summaryRow('Phí vận chuyển', shipping),
        const Divider(height: 16),
        _summaryRow('Tổng cộng', total, bold: true),
      ]));
  }

  Widget _summaryRow(String label, double value,
      {bool bold = false}) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 13,
          fontWeight:
              bold ? FontWeight.bold : FontWeight.w400)),
      const Spacer(),
      Text('${PriceFormatter.formatFull(value)}đ',
          style: TextStyle(fontSize: 14,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.w500,
              color: bold ? AppColors.primary : null)),
    ]);
  }

  Widget _actionButtons(
      String status, Map<String, dynamic> order,
      bool isVi) {
    if (status == 'delivered' || status == 'cancelled' || status == 'finding_driver') {
      return const SizedBox.shrink();
    }
    final next =
        status == 'pending' ? 'finding_driver' : 'delivered';
    final label = status == 'pending'
        ? (isVi ? 'Tìm Shipper' : 'Find Shipper')
        : (isVi ? 'Đánh dấu đã giao' : 'Mark Delivered');
    final icon = status == 'pending'
        ? Icons.search
        : Icons.local_shipping;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _updateStatus(order['id'], next),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)))));
  }

  Future<void> _updateStatus(
      String orderId, String status) async {
    final ok = await _shopDS.updateStatus(
        orderId, status);
    if (ok && mounted) {
      _fetch(); // refresh detail
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Cập nhật thành công!')));
    }
  }
}

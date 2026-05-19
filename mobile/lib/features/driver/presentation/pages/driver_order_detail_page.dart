import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../checkout/data/order_datasource.dart';
import '../widgets/driver_detail_cards.dart';

/// Order detail page specifically for Drivers.
class DriverOrderDetailPage extends StatefulWidget {
  /// Order ID to fetch details for.
  final String orderId;

  const DriverOrderDetailPage({
    super.key, required this.orderId});

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
        title: Text(isVi ? 'Chi tiết đơn giao'
            : 'Delivery Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator())
          : _detail == null
              ? Center(child: Text(isVi
                  ? 'Không tìm thấy đơn'
                  : 'Order not found'))
              : _buildContent(isVi, isDark));
  }

  Widget _buildContent(bool isVi, bool isDark) {
    final order =
        _detail!['order'] as Map<String, dynamic>;
    final items = (_detail!['items'] as List?) ?? [];
    final status = order['status'] ?? 'pending';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        DriverStatusCard(status: status, isVi: isVi),
        const SizedBox(height: 12),
        DriverAddressCard(
            order: order, isVi: isVi, isDark: isDark),
        const SizedBox(height: 12),
        DriverItemsCard(items: items, isDark: isDark),
        const SizedBox(height: 12),
        _summaryCard(order, isDark),
        const SizedBox(height: 24),
        _actionArea(status, order, isVi),
        const SizedBox(height: 16),
      ]));
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
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _summaryRow('Phí vận chuyển', shipping),
        const Divider(height: 16),
        _summaryRow('Tổng thu hộ (COD)', total,
            bold: true),
      ]));
  }

  Widget _summaryRow(String label, double value,
      {bool bold = false}) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 13,
          fontWeight: bold
              ? FontWeight.bold : FontWeight.w400)),
      const Spacer(),
      Text('${PriceFormatter.formatFull(value)}đ',
          style: TextStyle(fontSize: 14,
              fontWeight: bold
                  ? FontWeight.bold : FontWeight.w500,
              color: bold ? AppColors.primary : null)),
    ]);
  }

  Widget _actionArea(String status,
      Map<String, dynamic> order, bool isVi) {
    if (status == 'finding_driver') {
      return _actionButton(
        label: isVi ? 'Nhận Đơn Giao'
            : 'Accept & Deliver',
        icon: Icons.delivery_dining,
        color: Colors.purple,
        onPressed: () => _acceptOrder(order));
    }
    if (status == 'shipping') {
      return _actionButton(
        label: isVi ? 'Xác nhận đã giao'
            : 'Mark as Delivered',
        icon: Icons.check_circle_outline,
        color: Colors.green,
        onPressed: () => _markDelivered(order['id']));
    }
    return const SizedBox.shrink();
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _acting ? null : onPressed,
        icon: _acting
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon),
        label: Text(label, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)))));
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
        driverPhone: driverPhone);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Đã nhận đơn thành công!')));
        _fetch();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              '❌ Đơn đã được người khác nhận hoặc có lỗi')));
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
          const SnackBar(content: Text(
              '✅ Đã xác nhận giao hàng thành công!')));
        _fetch();
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../seller/data/shop_order_datasource.dart';
import '../../../seller/presentation/pages/seller_order_list_page.dart';

/// Order stats section for seller dashboard.
/// Fetches real counts and navigates to order list.
class SellerOrderStats extends StatefulWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Shop ID for fetching order counts.
  final String shopId;

  /// Creates the SellerOrderStats widget.
  const SellerOrderStats({
    super.key,
    required this.isVi,
    required this.shopId,
  });

  @override
  State<SellerOrderStats> createState() =>
      _SellerOrderStatsState();
}

class _SellerOrderStatsState
    extends State<SellerOrderStats> {
  final _ds = ShopOrderDatasource();
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    if (widget.shopId.isEmpty) return;
    final orders = await _ds.fetchShopOrders(
        widget.shopId);
    final counts = <String, int>{
      'pending': 0, 'cancelled': 0,
      'shipping': 0, 'delivered': 0,
    };
    for (final o in orders) {
      final s = o['status']?.toString() ?? '';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    if (mounted) setState(() => _counts = counts);
  }

  void _openOrders({int initialTab = 0}) async {
    await Navigator.push(context, MaterialPageRoute(
        builder: (_) => SellerOrderListPage(
            shopId: widget.shopId)));
    _fetchCounts(); // refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
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
          _header(),
          const SizedBox(height: 16),
          _statsRow(),
        ]));
  }

  Widget _header() {
    return Row(children: [
      const Icon(Icons.receipt_long, size: 20,
          color: Color(0xFF3A7BD5)),
      const SizedBox(width: 8),
      Text(widget.isVi ? 'Đơn hàng' : 'Orders',
          style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600)),
      const Spacer(),
      GestureDetector(
        onTap: () => _openOrders(),
        child: Text(
            widget.isVi ? 'Xem lịch sử >' : 'History >',
            style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontSize: 12,
                color: IndieFolkTheme.tertiary(Theme.of(context).brightness == Brightness.dark),
                fontWeight: FontWeight.w500))),
    ]);
  }

  Widget _statsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(
            '${_counts['pending'] ?? 0}',
            widget.isVi ? 'Chờ lấy\nhàng' : 'Pending',
            Icons.inventory_2_outlined,
            const Color(0xFFFF9800),
            onTap: _openOrders),
        _statItem(
            '${_counts['cancelled'] ?? 0}',
            widget.isVi ? 'Đơn hủy' : 'Cancelled',
            Icons.cancel_outlined,
            const Color(0xFFE53935),
            onTap: _openOrders),
        _statItem(
            '${_counts['shipping'] ?? 0}',
            widget.isVi ? 'Đang giao' : 'Shipping',
            Icons.local_shipping_outlined,
            const Color(0xFF7C4DFF),
            onTap: _openOrders),
        _statItem(
            '${_counts['delivered'] ?? 0}',
            widget.isVi ? 'Đã giao' : 'Delivered',
            Icons.check_circle_outline,
            const Color(0xFF00BFA5),
            onTap: _openOrders),
      ]);
  }

  Widget _statItem(String count, String label,
      IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 22, color: color)),
          const SizedBox(height: 6),
          Text(count, style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(
              fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontSize: 10),
              textAlign: TextAlign.center),
        ]));
  }
}

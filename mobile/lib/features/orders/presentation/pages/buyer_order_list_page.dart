import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../checkout/data/order_datasource.dart';

/// Buyer order list with status tabs (Shopee style).
class BuyerOrderListPage extends StatefulWidget {
  /// Optional initial tab index.
  final int initialTab;

  /// Creates BuyerOrderListPage.
  const BuyerOrderListPage({
    super.key, this.initialTab = 0});

  @override
  State<BuyerOrderListPage> createState() =>
      _BuyerOrderListPageState();
}

class _BuyerOrderListPageState
    extends State<BuyerOrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _ds = OrderDatasource();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  static const _statuses = [
    'all', 'pending', 'shipping', 'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
        length: _statuses.length,
        initialIndex: widget.initialTab,
        vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _loading = true);
    _orders = await _ds.fetchMyOrders();
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    final s = _statuses[_tabCtrl.index];
    if (s == 'all') return _orders;
    return _orders
        .where((o) => o['status'] == s).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(isVi ? 'Đơn đã mua' : 'My Orders'),
        backgroundColor: Colors.transparent, elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl, isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: isVi ? 'Tất cả' : 'All'),
            Tab(text: isVi ? 'Chờ xác nhận' : 'Pending'),
            Tab(text: isVi ? 'Đang giao' : 'Shipping'),
            Tab(text: isVi ? 'Đã giao' : 'Delivered'),
            Tab(text: isVi ? 'Đã hủy' : 'Cancelled'),
          ])),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator())
          : _buildBody(isDark, isVi));
  }

  Widget _buildBody(bool isDark, bool isVi) {
    final list = _filtered;
    if (list.isEmpty) return _emptyState(isDark, isVi);
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (_, i) =>
              _orderCard(list[i], isDark, isVi)));
  }

  Widget _emptyState(bool isDark, bool isVi) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.receipt_long_outlined, size: 64,
            color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(isVi ? 'Bạn chưa có đơn hàng nào cả'
            : 'No orders yet',
            style: TextStyle(fontSize: 15,
                color: Colors.grey.shade500)),
      ]));
  }

  Widget _orderCard(Map<String, dynamic> o,
      bool isDark, bool isVi) {
    final status = o['status'] ?? 'pending';
    final total = (o['total'] ?? 0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _statusBadge(status, isVi),
            const Spacer(),
            Text('#${(o['id'] ?? '').toString()
                .substring(0, 8)}',
                style: TextStyle(fontSize: 12,
                    color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.payments_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('${PriceFormatter.formatFull(total)}đ',
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const Spacer(),
            if (status == 'pending')
              _cancelBtn(o, isVi),
          ])]));
  }

  Widget _cancelBtn(
      Map<String, dynamic> o, bool isVi) {
    return SizedBox(height: 30, child: OutlinedButton(
      onPressed: () => _confirmCancel(o, isVi),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(
            horizontal: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6))),
      child: Text(isVi ? 'Hủy đơn' : 'Cancel',
          style: const TextStyle(fontSize: 12))));
  }

  Future<void> _confirmCancel(
      Map<String, dynamic> o, bool isVi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isVi ? 'Hủy đơn hàng'
            : 'Cancel order'),
        content: Text(isVi
            ? 'Bạn có chắc chắn muốn hủy đơn hàng này?'
            : 'Are you sure you want to cancel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isVi ? 'Không' : 'No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: Text(isVi ? 'Hủy đơn' : 'Cancel')),
        ]));
    if (confirmed == true) {
      final ok = await _ds.cancelOrder(o['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ok
                ? (isVi ? 'Đã hủy đơn hàng'
                    : 'Order cancelled')
                : (isVi ? 'Không thể hủy đơn'
                    : 'Failed to cancel'))));
        if (ok) _fetchOrders();
      }
    }
  }

  Widget _statusBadge(String status, bool isVi) {
    final labels = {
      'pending': isVi ? 'Chờ xác nhận' : 'Pending',
      'shipping': isVi ? 'Đang giao' : 'Shipping',
      'delivered': isVi ? 'Đã giao' : 'Delivered',
      'cancelled': isVi ? 'Đã hủy' : 'Cancelled',
    };
    final colors = {
      'pending': Colors.orange,
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
          style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors[status] ?? Colors.grey)));
  }
}


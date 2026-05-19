import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../checkout/data/order_datasource.dart';
import '../widgets/buyer_order_card.dart';

/// Buyer order list with status tabs.
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
    return _orders.where((o) {
      final status = o['status'];
      if (s == 'shipping') {
        return status == 'shipping'
            || status == 'finding_driver';
      }
      return status == s;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        title: Text(isVi ? 'Đơn đã mua' : 'My Orders',
            style: IndieFolkTheme.h1(isDark)
                .copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl, isScrollable: true,
          labelColor: IndieFolkTheme.tertiary(isDark),
          unselectedLabelColor:
              IndieFolkTheme.secondary(isDark),
          indicatorColor:
              IndieFolkTheme.tertiary(isDark),
          labelStyle: IndieFolkTheme.body(isDark)
              .copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              IndieFolkTheme.body(isDark),
          tabs: [
            Tab(text: isVi ? 'Tất cả' : 'All'),
            Tab(text: isVi ? 'Chờ xác nhận'
                : 'Pending'),
            Tab(text: isVi ? 'Đang giao'
                : 'Shipping'),
            Tab(text: isVi ? 'Đã giao'
                : 'Delivered'),
            Tab(text: isVi ? 'Đã hủy'
                : 'Cancelled'),
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
          itemBuilder: (_, i) => BuyerOrderCard(
              order: list[i],
              isDark: isDark,
              isVi: isVi,
              onCancel: () =>
                  _confirmCancel(list[i], isVi))));
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
            style: IndieFolkTheme.body(isDark).copyWith(
                fontSize: 15,
                color: IndieFolkTheme.secondary(
                    isDark))),
      ]));
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
            onPressed: () =>
                Navigator.pop(context, false),
            child: Text(isVi ? 'Không' : 'No')),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: Text(isVi ? 'Hủy đơn'
                : 'Cancel')),
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/shop_order_datasource.dart';
import 'seller_order_detail_page.dart';

/// Seller's order list with status tabs.
class SellerOrderListPage extends StatefulWidget {
  /// Shop ID for fetching orders.
  final String shopId;

  /// Creates SellerOrderListPage.
  const SellerOrderListPage({
    super.key, required this.shopId});

  @override
  State<SellerOrderListPage> createState() =>
      _SellerOrderListPageState();
}

class _SellerOrderListPageState
    extends State<SellerOrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _ds = ShopOrderDatasource();
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
        length: _statuses.length, vsync: this);
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
    _orders = await _ds.fetchShopOrders(widget.shopId);
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
        title: Text(isVi ? 'Đơn hàng' : 'Orders'),
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
    if (list.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 64,
              color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(isVi ? 'Chưa có đơn hàng nào'
              : 'No orders yet',
              style: TextStyle(fontSize: 15,
                  color: Colors.grey.shade500)),
        ]));
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (_, i) =>
              _orderCard(list[i], isDark, isVi)));
  }

  Widget _orderCard(Map<String, dynamic> o,
      bool isDark, bool isVi) {
    final status = o['status'] ?? 'pending';
    final total = (o['total'] ?? 0).toDouble();
    final name = o['receiver_name'] ?? '';
    final orderId = o['id']?.toString() ?? '';
    return GestureDetector(
      onTap: () => _viewDetail(o),
      child: Container(
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
              _badge(status, isVi),
              const Spacer(),
              if (orderId.length >= 8)
                Text('#${orderId.substring(0, 8)}',
                    style: TextStyle(fontSize: 12,
                        color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.person_outline, size: 16,
                  color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(name, style: TextStyle(fontSize: 13,
                  color: isDark
                      ? Colors.white
                      : Colors.black87)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.payments_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('${PriceFormatter.formatFull(total)}đ',
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ])])));
  }

  Widget _badge(String status, bool isVi) {
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

  void _viewDetail(Map<String, dynamic> o) async {
    final orderId = o['id']?.toString() ?? '';
    if (orderId.isEmpty) return;
    await Navigator.push(context, MaterialPageRoute(
        builder: (_) => SellerOrderDetailPage(
            orderId: orderId)));
    _fetchOrders(); // refresh on return
  }
}

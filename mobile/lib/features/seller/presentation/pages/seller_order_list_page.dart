import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/constants/api_constants.dart';
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
    return _orders.where((o) {
      final status = o['status'];
      if (s == 'shipping') {
        return status == 'shipping' || status == 'finding_driver';
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
        title: Text(isVi ? 'Đơn hàng' : 'Orders', style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent, elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl, isScrollable: true,
          labelColor: IndieFolkTheme.tertiary(isDark),
          unselectedLabelColor: IndieFolkTheme.secondary(isDark),
          indicatorColor: IndieFolkTheme.tertiary(isDark),
          labelStyle: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: IndieFolkTheme.body(isDark),
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
              style: IndieFolkTheme.body(isDark).copyWith(fontSize: 15,
                  color: IndieFolkTheme.secondary(isDark))),
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
          color: IndieFolkTheme.surface(isDark),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _badge(status, isVi),
            ]),
            const SizedBox(height: 12),
            if (o['items'] != null && (o['items'] as List).isNotEmpty) ...[
              _itemPreview(o['items'] as List, isDark, isVi),
              const SizedBox(height: 12),
            ],
            Row(children: [
              Icon(Icons.person_outline, size: 16,
                  color: IndieFolkTheme.secondary(isDark)),
              const SizedBox(width: 6),
              Text(name, style: IndieFolkTheme.body(isDark).copyWith(fontSize: 13,
                  fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.payments_outlined,
                  size: 16, color: IndieFolkTheme.tertiary(isDark)),
              const SizedBox(width: 6),
              Text('${PriceFormatter.formatFull(total)}đ',
                  style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: IndieFolkTheme.tertiary(isDark))),
            ])])));
  }

  Widget _itemPreview(List items, bool isDark, bool isVi) {
    final first = items.first;
    final name = first['product_name'] ?? '';
    final qty = first['quantity'] ?? 1;
    final image = ApiConstants.resolveImageUrl(first['product_image'] ?? '');
    final extra = items.length > 1 ? (items.length - 1) : 0;
    
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: image.isNotEmpty
            ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder())
            : _imgPlaceholder(),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: IndieFolkTheme.body(isDark).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        if (extra > 0) ...[
          const SizedBox(height: 4),
          Text(isVi ? '...và $extra sản phẩm khác' : '...and $extra more items',
              style: IndieFolkTheme.body(isDark).copyWith(fontSize: 11, color: IndieFolkTheme.tertiary(isDark))),
        ]
      ])),
      const SizedBox(width: 8),
      Text('x$qty', style: IndieFolkTheme.body(isDark).copyWith(fontSize: 13)),
    ]);
  }

  Widget _imgPlaceholder() {
    return Container(width: 50, height: 50, color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 24, color: Colors.grey));
  }

  Widget _badge(String status, bool isVi) {
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
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20)),
      child: Text(labels[status] ?? status,
          style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontSize: 12,
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

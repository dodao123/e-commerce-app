import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/data/order_datasource.dart';
import '../widgets/driver_order_card.dart';
import 'driver_order_detail_page.dart';

/// Driver orders list with status filter tabs.
class DriverOrderListPage extends StatefulWidget {
  /// Initial tab index.
  final int initialTab;

  /// Creates DriverOrderListPage.
  const DriverOrderListPage({
    super.key, this.initialTab = 0});

  @override
  State<DriverOrderListPage> createState() =>
      _DriverOrderListPageState();
}

class _DriverOrderListPageState
    extends State<DriverOrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _ds = OrderDatasource();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
        length: 4, vsync: this,
        initialIndex: widget.initialTab);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() { _loading = true; _error = ''; });
      _orders = await _ds.fetchDriverOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(isVi ? 'Đơn hàng của tôi'
            : 'My Orders'),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.surface : Colors.white,
        foregroundColor: isDark
            ? Colors.white : Colors.black87,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabCtrl, isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: isVi ? 'Tất cả' : 'All'),
            Tab(text: isVi ? 'Có Thể Nhận'
                : 'Picking Up'),
            Tab(text: isVi ? 'Đang giao'
                : 'Shipping'),
            Tab(text: isVi ? 'Đã giao'
                : 'Delivered'),
          ])),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(null, isDark, isVi),
                    _buildList(['finding_driver'],
                        isDark, isVi),
                    _buildList(['shipping'],
                        isDark, isVi),
                    _buildList(['delivered'],
                        isDark, isVi),
                  ]));
  }

  Widget _buildList(List<String>? statuses,
      bool isDark, bool isVi) {
    final list = statuses == null
        ? _orders
        : _orders.where((o) =>
            statuses.contains(o['status'])).toList();
    if (list.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64,
              color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(isVi ? 'Chưa có đơn hàng'
              : 'No orders yet',
              style: TextStyle(
                  color: Colors.grey.shade500)),
        ]));
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.only(
            top: 8, bottom: 24),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
        itemBuilder: (_, i) => DriverOrderCard(
          order: list[i],
          isDark: isDark,
          isVi: isVi,
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                    DriverOrderDetailPage(
                        orderId: list[i]['id'])));
            _fetchOrders();
          })));
  }
}

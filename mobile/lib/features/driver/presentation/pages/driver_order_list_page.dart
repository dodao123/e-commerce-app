import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../checkout/data/order_datasource.dart';
import 'driver_order_detail_page.dart';

/// Driver orders list matching Shopee seller/buyer style.
class DriverOrderListPage extends StatefulWidget {
  final int initialTab;
  const DriverOrderListPage({super.key, this.initialTab = 0});

  @override
  State<DriverOrderListPage> createState() => _DriverOrderListPageState();
}

class _DriverOrderListPageState extends State<DriverOrderListPage>
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
        length: 4, vsync: this, initialIndex: widget.initialTab);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });
      _orders = await _ds.fetchDriverOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(isVi ? 'Đơn hàng của tôi' : 'My Orders'),
        centerTitle: true,
        backgroundColor: isDark ? DarkColors.surface : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: isVi ? 'Tất cả' : 'All'),
            Tab(text: isVi ? 'Có Thể Nhận' : 'Picking Up'),
            Tab(text: isVi ? 'Đang giao' : 'Shipping'),
            Tab(text: isVi ? 'Đã giao' : 'Delivered'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(null, isDark, isVi),
                    _buildList(['finding_driver'], isDark, isVi),
                    _buildList(['shipping'], isDark, isVi),
                    _buildList(['delivered'], isDark, isVi),
                  ],
                ),
    );
  }

  Widget _buildList(List<String>? statuses, bool isDark, bool isVi) {
    final list = statuses == null
        ? _orders
        : _orders.where((o) => statuses.contains(o['status'])).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isVi ? 'Chưa có đơn hàng' : 'No orders yet',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _buildOrderCard(list[i], isDark, isVi),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark, bool isVi) {
    final status = order['status'] ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final first = items.first;
    final name = first['product_name'] ?? '';
    final qty = first['quantity'] ?? 1;
    final image = ApiConstants.resolveImageUrl(first['product_image'] ?? '');
    final extra = items.length > 1 ? (items.length - 1) : 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DriverOrderDetailPage(
                orderId: order['id']),
          ),
        );
        _fetchOrders();
      },
      child: Container(
        color: isDark ? DarkColors.surface : Colors.white,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn: ${order['id'].toString().split('-').first.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  _statusBadge(status, isVi),
                ],
              ),
            ),
            const Divider(height: 1),
            // Item preview
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: image.startsWith('http')
                        ? Image.network(
                            image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isVi ? 'x$qty sản phẩm' : 'x$qty items',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (extra > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  isVi ? 'Xem thêm $extra sản phẩm' : 'View $extra more products',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isVi ? 'Tổng tiền thu hộ:' : 'COD amount:',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    '${PriceFormatter.formatFull((order['total'] as num).toDouble())}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, bool isVi) {
    Color c;
    String text;
    switch (status) {
      case 'finding_driver':
        c = Colors.blue;
        text = isVi ? 'Đang lấy' : 'Picking Up';
        break;
      case 'shipping':
        c = Colors.orange;
        text = isVi ? 'Đang giao' : 'Shipping';
        break;
      case 'delivered':
        c = Colors.green;
        text = isVi ? 'Đã giao' : 'Delivered';
        break;
      case 'cancelled':
        c = Colors.red;
        text = isVi ? 'Đã huỷ' : 'Cancelled';
        break;
      default:
        c = Colors.grey;
        text = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}

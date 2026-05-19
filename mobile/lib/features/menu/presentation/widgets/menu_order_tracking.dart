import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../checkout/data/order_datasource.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/notification_polling_service.dart';
import 'package:provider/provider.dart';
import '../../../orders/presentation/pages/buyer_order_list_page.dart';

/// Order tracking section with status icons + badges.
/// Fetches order counts from API and shows on icons.
class MenuOrderTracking extends StatefulWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the MenuOrderTracking widget.
  const MenuOrderTracking({
    super.key, required this.isVi});

  @override
  State<MenuOrderTracking> createState() =>
      _MenuOrderTrackingState();
}

class _MenuOrderTrackingState
    extends State<MenuOrderTracking> {
  final _ds = OrderDatasource();
  Map<String, int> _counts = {};
  late AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _fetchCounts();
    NotificationPollingService().unreadCount.addListener(_fetchCounts);
    _appProvider.orderUpdateTrigger.addListener(_fetchCounts);
  }

  @override
  void dispose() {
    NotificationPollingService().unreadCount.removeListener(_fetchCounts);
    _appProvider.orderUpdateTrigger.removeListener(_fetchCounts);
    super.dispose();
  }

  Future<void> _fetchCounts() async {
    final orders = await _ds.fetchMyOrders();
    final map = <String, int>{};
    for (final o in orders) {
      final s = o['status']?.toString() ?? '';
      map[s] = (map[s] ?? 0) + 1;
    }
    if (mounted) setState(() => _counts = map);
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
          Row(children: [
            Text(widget.isVi ? 'Đơn mua' : 'My Orders',
                style: IndieFolkTheme.body(isDark).copyWith(fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: () => _openOrders(context, 0),
              child: Text(
                  widget.isVi ? 'Xem lịch sử >'
                      : 'View history >',
                  style: IndieFolkTheme.body(isDark).copyWith(fontSize: 12,
                      color: IndieFolkTheme.tertiary(isDark),
                      fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _statusIcon(Icons.receipt_long_outlined,
                  widget.isVi ? 'Chờ xác nhận' : 'Pending',
                  _counts['pending'] ?? 0,
                  () => _openOrders(context, 1)),
              _statusIcon(Icons.local_shipping_outlined,
                  widget.isVi ? 'Đang giao' : 'Shipping',
                  (_counts['shipping'] ?? 0) + (_counts['finding_driver'] ?? 0),
                  () => _openOrders(context, 2)),
              _statusIcon(Icons.check_circle_outline,
                  widget.isVi ? 'Đã giao' : 'Delivered',
                  _counts['delivered'] ?? 0,
                  () => _openOrders(context, 3)),
              _statusIcon(Icons.star_outline_rounded,
                  widget.isVi ? 'Đánh giá' : 'Review',
                  0, null),
            ]),
        ]));
  }

  void _openOrders(BuildContext context, int tab) async {
    await Navigator.push(context, MaterialPageRoute(
        builder: (_) => BuyerOrderListPage(
            initialTab: tab)));
    _fetchCounts();
  }

  Widget _statusIcon(IconData icon, String label,
      int count, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: IndieFolkTheme.tertiary(Theme.of(context).brightness == Brightness.dark)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 26,
                  color: IndieFolkTheme.tertiary(Theme.of(context).brightness == Brightness.dark))),
            if (count > 0)
              Positioned(right: -6, top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle),
                  constraints: const BoxConstraints(
                      minWidth: 18, minHeight: 18),
                  child: Text('$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)))),
          ]),
          const SizedBox(height: 6),
          Text(label,
              style: IndieFolkTheme.body(Theme.of(context).brightness == Brightness.dark).copyWith(fontSize: 11),
              textAlign: TextAlign.center),
        ]));
  }
}

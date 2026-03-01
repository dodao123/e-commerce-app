import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/shop_order_datasource.dart';
import '../pages/product_management_page.dart';
import '../pages/seller_order_list_page.dart';

/// Grid of quick action buttons for the shop dashboard.
class ShopQuickActions extends StatefulWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Whether the theme is dark.
  final bool isDark;

  /// Shop ID for order queries.
  final String shopId;

  /// Creates a ShopQuickActions widget.
  const ShopQuickActions({
    super.key,
    required this.isVi,
    required this.isDark,
    required this.shopId,
  });

  @override
  State<ShopQuickActions> createState() =>
      _ShopQuickActionsState();
}

class _ShopQuickActionsState
    extends State<ShopQuickActions> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPendingCount();
  }

  Future<void> _fetchPendingCount() async {
    if (widget.shopId.isEmpty) return;
    final count = await ShopOrderDatasource()
        .fetchPendingCount(widget.shopId);
    if (mounted) setState(() => _pendingCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Icons.inventory_2_outlined,
          widget.isVi ? 'Sản phẩm' : 'Products',
          const Color(0xFF4A3ADB),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  const ProductManagementPage()))),
      _Action(Icons.receipt_long_outlined,
          widget.isVi ? 'Đơn hàng' : 'Orders',
          const Color(0xFFEF6C4A),
          badge: _pendingCount,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  SellerOrderListPage(
                      shopId: widget.shopId)))),
      _Action(Icons.bar_chart_outlined,
          widget.isVi ? 'Thống kê' : 'Analytics',
          const Color(0xFF00D2D3)),
      _Action(Icons.settings_outlined,
          widget.isVi ? 'Cài đặt' : 'Settings',
          Colors.grey.shade600),
    ];

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((a) => _tile(a)).toList());
  }

  Widget _tile(_Action action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark
              ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(action.icon,
                    color: action.color, size: 22)),
              if (action.badge > 0)
                Positioned(right: -6, top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle),
                    constraints: const BoxConstraints(
                        minWidth: 18, minHeight: 18),
                    child: Text('${action.badge}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  )),
            ]),
            const SizedBox(height: 10),
            Text(action.label, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? DarkColors.textPrimary
                    : Colors.black87)),
          ])));
  }
}

/// Internal action model.
class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int badge;
  const _Action(this.icon, this.label, this.color,
      {this.onTap, this.badge = 0});
}

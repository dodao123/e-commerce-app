import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/shop_order_datasource.dart';
import '../pages/product_management_page.dart';
import '../pages/seller_order_list_page.dart';
import '../pages/shop_settings_page.dart';

import '../../../chat/presentation/pages/chat_rooms_page.dart';

/// Grid of quick action buttons for the shop dashboard.
class ShopQuickActions extends StatefulWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Whether the theme is dark.
  final bool isDark;

  /// Shop data map from API.
  final Map<String, dynamic> shopData;

  /// Callback when settings/data gets updated and needs refresh.
  final VoidCallback onRefresh;

  /// Creates a ShopQuickActions widget.
  const ShopQuickActions({
    super.key,
    required this.isVi,
    required this.isDark,
    required this.shopData,
    required this.onRefresh,
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
    final shopId = widget.shopData['id']?.toString() ?? '';
    if (shopId.isEmpty) return;
    final count = await ShopOrderDatasource()
        .fetchPendingCount(shopId);
    if (mounted) setState(() => _pendingCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final shopId = widget.shopData['id']?.toString() ?? '';
    final actions = [
      _Action(Icons.inventory_2_outlined,
          widget.isVi ? 'Sản phẩm' : 'Products',
          IndieFolkTheme.tertiary(widget.isDark),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  const ProductManagementPage()))),
      _Action(Icons.receipt_long_outlined,
          widget.isVi ? 'Đơn hàng' : 'Orders',
          IndieFolkTheme.tertiary(widget.isDark),
          badge: _pendingCount,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  SellerOrderListPage(
                      shopId: shopId)))),
      _Action(Icons.chat_outlined,
          widget.isVi ? 'Tin nhắn' : 'Messages',
          IndieFolkTheme.tertiary(widget.isDark),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  const ChatRoomsPage()))),
      _Action(Icons.bar_chart_outlined,
          widget.isVi ? 'Thống kê' : 'Analytics',
          IndieFolkTheme.tertiary(widget.isDark)),
      _Action(Icons.settings_outlined,
          widget.isVi ? 'Cài đặt' : 'Settings',
          IndieFolkTheme.secondary(widget.isDark),
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                    ShopSettingsPage(shopData: widget.shopData)));
            widget.onRefresh();
          }),
    ];

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions.map((a) => _tile(a)).toList());
  }

  Widget _tile(_Action action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IndieFolkTheme.surface(widget.isDark),
          borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
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
                        style: IndieFolkTheme.label(widget.isDark).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )),
            ]),
            const SizedBox(height: 10),
            Text(action.label, style: IndieFolkTheme.body(widget.isDark).copyWith(
                fontWeight: FontWeight.w600)),
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

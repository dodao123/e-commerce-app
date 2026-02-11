import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/product_management_page.dart';

/// Grid of quick action buttons for the shop dashboard.
class ShopQuickActions extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Whether the theme is dark.
  final bool isDark;

  /// Creates a ShopQuickActions widget.
  const ShopQuickActions({
    super.key, required this.isVi, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Icons.inventory_2_outlined,
          isVi ? 'Sản phẩm' : 'Products', const Color(0xFF4A3ADB),
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ProductManagementPage()))),
      _Action(Icons.receipt_long_outlined,
          isVi ? 'Đơn hàng' : 'Orders', const Color(0xFFEF6C4A)),
      _Action(Icons.bar_chart_outlined,
          isVi ? 'Thống kê' : 'Analytics', const Color(0xFF00D2D3)),
      _Action(Icons.settings_outlined,
          isVi ? 'Cài đặt' : 'Settings', Colors.grey.shade600),
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
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(action.icon, color: action.color, size: 22)),
          const SizedBox(height: 10),
          Text(action.label, style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkColors.textPrimary : Colors.black87)),
        ])));
  }
}

/// Internal action model.
class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Action(this.icon, this.label, this.color, {this.onTap});
}

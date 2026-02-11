import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../seller/presentation/pages/product_management_page.dart';

/// Seller tools grid: My Products, Sales Performance,
/// Advertising, Marketing, Support Center.
class SellerTools extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the SellerTools widget.
  const SellerTools({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isVi ? 'Công cụ bán hàng' : 'Seller Tools',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // First row: 3 items
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _toolItem(Icons.storefront_outlined,
                  isVi ? 'Sản phẩm\ncủa tôi' : 'My\nProducts',
                  const Color(0xFF3A7BD5),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                        const ProductManagementPage()))),
              _toolItem(Icons.trending_up_rounded,
                  isVi ? 'Hiệu quả\nbán hàng' : 'Sales\nPerformance',
                  const Color(0xFFFF6D00)),
              _toolItem(Icons.campaign_outlined,
                  isVi ? 'Quảng cáo' : 'Advertising',
                  const Color(0xFFE53935)),
            ]),
          const SizedBox(height: 16),
          // Second row: 2 items
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolItem(Icons.share_outlined,
                  isVi ? 'Kênh\nMarketing' : 'Marketing\nChannel',
                  const Color(0xFF00BFA5)),
              _toolItem(Icons.support_agent_outlined,
                  isVi ? 'Trung tâm\nhỗ trợ' : 'Support\nCenter',
                  const Color(0xFF7C4DFF)),
            ]),
        ]),
    );
  }

  Widget _toolItem(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(width: 90,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2))),
            child: Icon(icon, size: 26, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center),
        ])),
    );
  }
}

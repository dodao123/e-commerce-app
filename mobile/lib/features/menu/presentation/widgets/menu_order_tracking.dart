import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Order tracking section with 4 status icons.
/// Shows: Chờ xác nhận → Chờ lấy hàng → Chờ giao hàng → Đánh giá
class MenuOrderTracking extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the MenuOrderTracking widget.
  const MenuOrderTracking({super.key, required this.isVi});

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
          Row(children: [
            Text(isVi ? 'Đơn mua' : 'My Orders',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(isVi ? 'Xem lịch sử >' : 'View history >',
                style: TextStyle(fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusIcon(Icons.receipt_long_outlined,
                  isVi ? 'Chờ xác nhận' : 'Pending', null),
              _statusIcon(Icons.inventory_2_outlined,
                  isVi ? 'Chờ lấy hàng' : 'Pickup', null),
              _statusIcon(Icons.local_shipping_outlined,
                  isVi ? 'Đang giao' : 'Shipping', '1'),
              _statusIcon(Icons.star_outline_rounded,
                  isVi ? 'Đánh giá' : 'Review', null),
            ],
          ),
        ]),
    );
  }

  Widget _statusIcon(IconData icon, String label, String? badge) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, size: 26, color: AppColors.primary)),
        if (badge != null)
          Positioned(right: -4, top: -4,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Center(child: Text(badge,
                  style: const TextStyle(color: Colors.white,
                      fontSize: 10, fontWeight: FontWeight.bold))))),
      ]),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center),
    ]);
  }
}

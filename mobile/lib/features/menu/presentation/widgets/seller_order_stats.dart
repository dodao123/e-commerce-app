import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Order stats section for seller dashboard.
/// Shows: Chờ lấy hàng, Đơn hủy, Trả hàng/Hoàn tiền, Phản hồi đánh giá.
class SellerOrderStats extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the SellerOrderStats widget.
  const SellerOrderStats({super.key, required this.isVi});

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
            const Icon(Icons.receipt_long, size: 20,
                color: Color(0xFF3A7BD5)),
            const SizedBox(width: 8),
            Text(isVi ? 'Đơn hàng' : 'Orders',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(isVi ? 'Xem lịch sử >' : 'History >',
                style: const TextStyle(fontSize: 12,
                    color: Color(0xFF3A7BD5),
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('0', isVi ? 'Chờ lấy\nhàng' : 'Pending\nPickup',
                  Icons.inventory_2_outlined, const Color(0xFFFF9800)),
              _statItem('0', isVi ? 'Đơn hủy' : 'Cancelled',
                  Icons.cancel_outlined, const Color(0xFFE53935)),
              _statItem('0', isVi ? 'Trả hàng\nHoàn tiền' : 'Returns\nRefunds',
                  Icons.swap_horiz_rounded, const Color(0xFF7C4DFF)),
              _statItem('0', isVi ? 'Phản hồi\nđánh giá' : 'Review\nFeedback',
                  Icons.rate_review_outlined, const Color(0xFF00BFA5)),
            ]),
        ]),
    );
  }

  Widget _statItem(String count, String label,
      IconData icon, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 22, color: color)),
      const SizedBox(height: 6),
      Text(count, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center),
    ]);
  }
}

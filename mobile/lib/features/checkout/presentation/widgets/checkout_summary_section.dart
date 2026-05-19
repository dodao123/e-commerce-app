import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Summary section widgets for checkout page.
class CheckoutSummarySection extends StatelessWidget {
  /// Subtotal amount.
  final double subtotal;

  /// Shipping fee amount.
  final double shippingFee;

  /// Total amount.
  final double total;

  /// Whether the app is in Vietnamese mode.
  final bool isVi;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates CheckoutSummarySection.
  const CheckoutSummarySection({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.isVi,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _costRow(isVi ? 'Tổng tiền hàng' : 'Subtotal',
              subtotal),
          const SizedBox(height: 6),
          _costRow(isVi ? 'Tổng tiền phí vận chuyển'
              : 'Shipping fee', shippingFee),
          const Divider(height: 20),
          _costRow(isVi ? 'Tổng thanh toán' : 'Total',
              total, isBold: true, isAccent: true),
        ])));
  }

  Widget _costRow(String label, double amount,
      {bool isBold = false, bool isAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13,
            color: isBold ? Colors.black87
                : Colors.grey.shade600,
            fontWeight: isBold
                ? FontWeight.w600 : FontWeight.normal)),
        Text('${PriceFormatter.formatFull(amount)}đ',
            style: TextStyle(fontSize: isBold ? 15 : 13,
                fontWeight: isBold
                    ? FontWeight.bold : FontWeight.w500,
                color: isAccent
                    ? AppColors.primary
                    : Colors.black87)),
      ]);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';

/// Bottom bar with select-all, selected total price, and checkout.
/// Only selected items count toward the displayed total.
class CartBottomBar extends StatelessWidget {
  /// Whether dark theme is active.
  final bool isDark;

  /// Whether current locale is Vietnamese.
  final bool isVi;

  /// Creates the CartBottomBar.
  const CartBottomBar({
    super.key,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // Select all checkbox
          GestureDetector(
            onTap: () => cart.toggleAll(),
            child: Row(children: [
              Icon(
                cart.isAllSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 22,
                color: cart.isAllSelected
                    ? AppColors.primary
                    : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(isVi ? 'Chọn tất cả' : 'Select all',
                  style: TextStyle(fontSize: 13,
                      color: isDark
                          ? DarkColors.textSecondary
                          : Colors.grey.shade600)),
            ]),
          ),
          const Spacer(),
          // Selected total price
          Text(
              '${PriceFormatter.format(cart.selectedTotalPrice)}'
              ' VND',
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white : Colors.black)),
          const SizedBox(width: 12),
          // Checkout button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0),
            child: Text(isVi ? 'Kiểm tra' : 'Checkout',
                style: const TextStyle(
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}

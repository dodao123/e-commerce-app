import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Utilities section: Voucher, E-wallet link, Bank link.
class MenuUtilities extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the MenuUtilities widget.
  const MenuUtilities({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isVi ? 'Tiện ích của tôi' : 'My Utilities',
              style: IndieFolkTheme.body(isDark).copyWith(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _utilityItem(context, Icons.discount_outlined,
                  isVi ? 'Voucher\ngiảm giá' : 'Discount\nVoucher',
                  const Color(0xFFFF7043)),
              _utilityItem(context, Icons.account_balance_wallet_outlined,
                  isVi ? 'Liên kết\nVí điện tử' : 'Link\nE-Wallet',
                  const Color(0xFF42A5F5)),
              _utilityItem(context, Icons.account_balance_outlined,
                  isVi ? 'Liên kết\nNgân hàng' : 'Link\nBank',
                  const Color(0xFF66BB6A)),
            ],
          ),
        ]),
    );
  }

  Widget _utilityItem(BuildContext context, IconData icon, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 28, color: color)),
        const SizedBox(height: 8),
        Text(label, style: IndieFolkTheme.body(isDark).copyWith(fontSize: 11),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

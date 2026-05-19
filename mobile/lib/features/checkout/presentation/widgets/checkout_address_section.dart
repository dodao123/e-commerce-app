import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Address section widget for checkout page.
class CheckoutAddressSection extends StatelessWidget {
  /// Selected address data.
  final Map<String, dynamic>? address;

  /// Whether the app is in Vietnamese mode.
  final bool isVi;

  /// Whether dark mode is active.
  final bool isDark;

  /// Called when user taps to add/change address.
  final VoidCallback onTap;

  /// Creates CheckoutAddressSection.
  const CheckoutAddressSection({
    super.key,
    required this.address,
    required this.isVi,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isDark ? DarkColors.surface : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: address == null
              ? _emptyAddress()
              : _filledAddress(),
        ),
      ),
    );
  }

  Widget _emptyAddress() {
    return Row(children: [
      const Icon(Icons.add_location_alt,
          color: AppColors.primary, size: 22),
      const SizedBox(width: 12),
      Text(isVi ? 'Thêm địa chỉ nhận hàng'
          : 'Add delivery address',
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _filledAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on,
            color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(address!['receiver_name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(width: 8),
              Text(address!['phone'] ?? '',
                  style: TextStyle(fontSize: 13,
                      color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 4),
            Text(_fmtAddress(address!),
                style: TextStyle(fontSize: 13,
                    color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]);
  }

  String _fmtAddress(Map<String, dynamic> a) {
    return [a['detail_address'], a['ward'],
        a['district'], a['province']]
        .where((s) => s != null
            && s.toString().isNotEmpty)
        .join(', ');
  }
}

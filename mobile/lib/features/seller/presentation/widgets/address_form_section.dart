import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Form section for address picker: name, phone, area, street.
class AddressFormSection extends StatelessWidget {
  /// Full name controller.
  final TextEditingController nameController;

  /// Phone number controller.
  final TextEditingController phoneController;

  /// Street address controller.
  final TextEditingController streetController;

  /// Selected area display text.
  final String areaText;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Callback when area field is tapped.
  final VoidCallback onAreaTap;

  /// Creates the AddressFormSection widget.
  const AddressFormSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.streetController,
    required this.areaText,
    required this.isDark,
    required this.isVi,
    required this.onAreaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(isVi
              ? 'Địa chỉ (dùng thông tin trước sắp nhập)'
              : 'Address (pre-fill info)'),
          const SizedBox(height: 16),
          _labeled(isVi ? 'Họ và tên' : 'Full Name',
              nameController),
          _divider(),
          _labeled(isVi ? 'Số điện thoại' : 'Phone',
              phoneController),
          _divider(),
          _tap(isVi ? 'Tỉnh/Thành phố, Quận/Huyện, Phường/Xã'
              : 'Province, District, Ward',
              areaText, onAreaTap),
          _divider(),
          _labeled(isVi ? 'Tên đường, Toà nhà, Số nhà'
              : 'Street, Building, Number',
              streetController),
        ]));
  }

  Widget _header(String text) => Text(text,
      style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? DarkColors.textPrimary
              : Colors.black87));

  Widget _divider() => Divider(height: 24, color: isDark
      ? DarkColors.textSecondary.withOpacity(0.2) : null);

  Widget _labeled(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11,
            color: isDark ? DarkColors.textSecondary
                : Colors.grey.shade500)),
        const SizedBox(height: 4),
        TextField(controller: ctrl,
          style: TextStyle(fontSize: 15, color: isDark
              ? DarkColors.textPrimary : Colors.black87),
          decoration: InputDecoration(
            border: InputBorder.none, isDense: true,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(color: isDark
                ? DarkColors.textSecondary
                : Colors.grey.shade400))),
      ]);
  }

  Widget _tap(String label, String value, VoidCallback onTap) {
    final hasVal = value.isNotEmpty;
    return InkWell(onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade500)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: Text(
                hasVal ? value
                    : (isVi ? 'Chọn khu vực'
                        : 'Select area'),
                style: TextStyle(fontSize: 15,
                    color: hasVal
                        ? (isDark ? DarkColors.textPrimary
                            : Colors.black87)
                        : (isDark ? DarkColors.textSecondary
                            : Colors.grey.shade400)))),
            Icon(Icons.chevron_right, color: isDark
                ? DarkColors.textSecondary
                : Colors.grey.shade400),
          ]),
        ]));
  }
}

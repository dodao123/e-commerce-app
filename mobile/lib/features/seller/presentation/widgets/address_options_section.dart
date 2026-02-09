import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Address options: toggles for default/pickup and type chips.
class AddressOptionsSection extends StatelessWidget {
  /// Whether this is the default address.
  final bool isDefault;

  /// Whether this is a pickup address.
  final bool isPickup;

  /// Selected address type index (0=Office, 1=Home).
  final int typeIndex;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Callback when default toggle changes.
  final ValueChanged<bool> onDefaultChanged;

  /// Callback when pickup toggle changes.
  final ValueChanged<bool> onPickupChanged;

  /// Callback when type chip is selected.
  final ValueChanged<int> onTypeChanged;

  /// Creates the AddressOptionsSection widget.
  const AddressOptionsSection({
    super.key,
    required this.isDefault, required this.isPickup,
    required this.typeIndex, required this.isDark,
    required this.isVi,
    required this.onDefaultChanged,
    required this.onPickupChanged,
    required this.onTypeChanged,
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
      child: Column(children: [
        _toggle(isVi ? 'Đặt làm địa chỉ mặc định'
            : 'Set as default address',
            isDefault, onDefaultChanged),
        Divider(height: 8, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        _toggle(isVi ? 'Đặt làm địa chỉ lấy hàng'
            : 'Set as pickup address',
            isPickup, onPickupChanged),
        Divider(height: 16, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2)
            : null),
        _typeChips(),
      ]));
  }

  Widget _toggle(String label, bool value,
      ValueChanged<bool> onChanged) {
    return Row(children: [
      Expanded(child: Text(label, style: TextStyle(
          fontSize: 14, color: isDark
              ? DarkColors.textPrimary : Colors.black87))),
      Switch.adaptive(value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged),
    ]);
  }

  Widget _typeChips() {
    final labels = isVi
        ? ['Văn Phòng', 'Nhà Riêng']
        : ['Office', 'Home'];
    return Row(children: [
      Text(isVi ? 'Loại địa chỉ:' : 'Address type:',
          style: TextStyle(fontSize: 14, color: isDark
              ? DarkColors.textPrimary : Colors.black87)),
      const Spacer(),
      ...List.generate(2, (i) => Padding(
        padding: const EdgeInsets.only(left: 6),
        child: ChoiceChip(
          label: Text(labels[i]),
          selected: typeIndex == i,
          selectedColor: AppColors.primary.withOpacity(0.15),
          backgroundColor: isDark ? DarkColors.surface : null,
          onSelected: (_) => onTypeChanged(i),
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          labelStyle: TextStyle(fontSize: 12,
              color: typeIndex == i ? AppColors.primary
                  : (isDark ? DarkColors.textSecondary
                      : Colors.black54),
              fontWeight: typeIndex == i
                  ? FontWeight.w600
                  : FontWeight.normal)))),
    ]);
  }
}

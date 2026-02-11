import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Product condition selector: New or Used with optional note.
class ProductConditionPicker extends StatelessWidget {
  /// Whether the item is new (true) or used (false).
  final bool isNew;

  /// Called when user changes the condition.
  final ValueChanged<bool> onChanged;

  /// Controller for the condition note (e.g., "99% new").
  final TextEditingController noteController;

  /// Whether the theme is dark.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the ProductConditionPicker widget.
  const ProductConditionPicker({
    super.key,
    required this.isNew,
    required this.onChanged,
    required this.noteController,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? DarkColors.surface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isVi ? 'Tình trạng hàng' : 'Condition',
            style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _chip(isVi ? 'Mới' : 'New', true),
            const SizedBox(width: 10),
            _chip(isVi ? 'Đã qua sử dụng' : 'Used', false),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: noteController,
            style: TextStyle(fontSize: 14,
              color: isDark ? DarkColors.textPrimary : Colors.black87),
            decoration: InputDecoration(
              hintText: isVi
                  ? 'Ghi chú VD: Mới 99%'
                  : 'Note e.g. 99% new',
              hintStyle: TextStyle(fontSize: 13,
                color: isDark
                    ? DarkColors.textSecondary
                    : Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? DarkColors.textSecondary.withOpacity(0.3)
                      : Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? DarkColors.textSecondary.withOpacity(0.3)
                      : Colors.grey.shade300)))),
        ]));
  }

  Widget _chip(String label, bool value) {
    final selected = isNew == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade400,
            width: selected ? 1.5 : 1)),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: selected ? AppColors.primary : Colors.grey.shade600))));
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

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
      color: IndieFolkTheme.surface(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isVi ? 'Tình trạng hàng' : 'Condition',
            style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _chip(isVi ? 'Mới' : 'New', true),
            const SizedBox(width: 10),
            _chip(isVi ? 'Đã qua sử dụng' : 'Used', false),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: noteController,
            style: IndieFolkTheme.body(isDark),
            decoration: InputDecoration(
              hintText: isVi
                  ? 'Ghi chú VD: Mới 99%'
                  : 'Note e.g. 99% new',
              hintStyle: IndieFolkTheme.body(isDark).copyWith(
                color: IndieFolkTheme.secondary(isDark).withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: IndieFolkTheme.secondary(isDark).withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: IndieFolkTheme.secondary(isDark).withOpacity(0.3))))),
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
              ? IndieFolkTheme.tertiary(isDark).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? IndieFolkTheme.tertiary(isDark) : IndieFolkTheme.secondary(isDark).withOpacity(0.5),
            width: selected ? 1.5 : 1)),
        child: Text(label, style: IndieFolkTheme.body(isDark).copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? IndieFolkTheme.tertiary(isDark) : IndieFolkTheme.secondary(isDark)))));
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_option_group.dart';

/// Body section with option chips and quantity selector.
class OptionSheetBody extends StatelessWidget {
  /// The product with options.
  final ProductModel product;

  /// Current selections: {groupName: selectedValue}.
  final Map<String, String> selections;

  /// Current quantity.
  final int quantity;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Callback when an option is selected.
  final void Function(String groupName, String value) onSelect;

  /// Callback when quantity changes.
  final void Function(int quantity) onQuantityChanged;

  /// Creates the body widget.
  const OptionSheetBody({
    super.key,
    required this.product,
    required this.selections,
    required this.quantity,
    required this.isDark,
    required this.isVi,
    required this.onSelect,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...product.options.map(_buildOptionGroup),
          const SizedBox(height: 16),
          _quantityRow(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(ProductOptionGroup group) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: IndieFolkTheme.primary(isDark),
              )),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final value in group.values)
              _optionChip(group.name, value),
          ]),
        ],
      ),
    );
  }

  Widget _optionChip(String groupName, String value) {
    final selected = selections[groupName] == value;
    final accent = IndieFolkTheme.tertiary(isDark);

    return GestureDetector(
      onTap: () => onSelect(groupName, value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? accent.withOpacity(0.12)
              : IndieFolkTheme.surface(isDark),
          border: Border.all(
            color: selected ? accent : IndieFolkTheme
                .secondary(isDark).withOpacity(0.3),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected
                  ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? accent
                  : IndieFolkTheme.primary(isDark),
            )),
      ),
    );
  }

  Widget _quantityRow() {
    return Row(children: [
      Text(isVi ? 'Số lượng' : 'Quantity',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: IndieFolkTheme.primary(isDark),
          )),
      const Spacer(),
      _quantityButton(Icons.remove, quantity > 1
          ? () => onQuantityChanged(quantity - 1) : null),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('$quantity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: IndieFolkTheme.primary(isDark),
            )),
      ),
      _quantityButton(Icons.add,
          () => onQuantityChanged(quantity + 1)),
    ]);
  }

  Widget _quantityButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: IndieFolkTheme.secondary(isDark)
                .withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null
                ? IndieFolkTheme.primary(isDark)
                : IndieFolkTheme.secondary(isDark)
                    .withOpacity(0.4)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../home/data/models/product_option_group.dart';
import 'option_group_tile.dart';

/// Widget for editing product option groups in seller forms.
/// Allows adding/removing option groups and values.
class ProductOptionsEditor extends StatelessWidget {
  /// Current list of option groups.
  final List<ProductOptionGroup> options;

  /// Callback when options are updated.
  final void Function(List<ProductOptionGroup>) onChanged;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the options editor widget.
  const ProductOptionsEditor({
    super.key,
    required this.options,
    required this.onChanged,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          ...options.asMap().entries.map(_buildGroup),
          _addGroupButton(),
        ],
      ),
    );
  }

  Widget _header() => Text(
        isVi ? 'Tùy chọn sản phẩm' : 'Product Options',
        style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 16),
      );

  Widget _buildGroup(MapEntry<int, ProductOptionGroup> entry) {
    final idx = entry.key;
    final group = entry.value;
    return OptionGroupTile(
      group: group,
      isDark: isDark,
      isVi: isVi,
      onNameChanged: (name) => _updateName(idx, name),
      onValuesChanged: (vals) => _updateValues(idx, vals),
      onRemove: () => _removeGroup(idx),
    );
  }

  Widget _addGroupButton() => TextButton.icon(
        onPressed: _addGroup,
        icon: Icon(Icons.add_circle_outline,
            color: IndieFolkTheme.tertiary(isDark), size: 20),
        label: Text(
          isVi ? 'Thêm nhóm tùy chọn' : 'Add option group',
          style: TextStyle(
            color: IndieFolkTheme.tertiary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  void _addGroup() {
    onChanged([...options, const ProductOptionGroup(
        name: '', values: [])]);
  }

  void _removeGroup(int index) {
    final updated = List<ProductOptionGroup>.from(options)
      ..removeAt(index);
    onChanged(updated);
  }

  void _updateName(int index, String name) {
    final updated = List<ProductOptionGroup>.from(options);
    updated[index] = ProductOptionGroup(
        name: name, values: options[index].values);
    onChanged(updated);
  }

  void _updateValues(int index, List<String> values) {
    final updated = List<ProductOptionGroup>.from(options);
    updated[index] = ProductOptionGroup(
        name: options[index].name, values: values);
    onChanged(updated);
  }
}
